import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { buildEchoPages, validateEntry } from '../../scripts/build-echo-pages.mjs';

async function fixture(t, changes = {}) {
  const temporary = await mkdtemp(path.join(os.tmpdir(), 'echo-pages-'));
  t.after(() => rm(temporary, { recursive: true, force: true }));
  const source = path.join(temporary, 'echo_life');
  const files = {
    'v40.html': '<!doctype html><title>Untouched v40</title>',
    'v41.html': '<link rel="stylesheet" href="./v41/styles.css"><script type="module" src="./v41/app.js"></script>',
    'v41/app.js': 'import { game } from "./game.js"; export { game };',
    'v41/game.js': 'export const game = 41;',
    'v41/styles.css': 'body { background: url("./city.svg"); }',
    'v41/city.svg': '<svg xmlns="http://www.w3.org/2000/svg"/>',
    ...changes,
  };
  for (const [filename, contents] of Object.entries(files)) {
    if (contents === null) continue;
    const target = path.join(source, filename);
    await mkdir(path.dirname(target), { recursive: true });
    await writeFile(target, contents);
  }
  return { sourceDir: source, outputDir: path.join(temporary, 'site') };
}

test('stages historical and nested URLs with unchanged game files', async t => {
  const options = await fixture(t);
  const result = await buildEchoPages(options);
  assert.deepEqual(result.assets, ['v41.html', 'v41/app.js', 'v41/city.svg', 'v41/game.js', 'v41/styles.css']);
  for (const filename of ['v40.html', ...result.assets]) {
    const original = await readFile(path.join(options.sourceDir, filename));
    assert.deepEqual(await readFile(path.join(options.outputDir, filename)), original);
    assert.deepEqual(await readFile(path.join(options.outputDir, 'echo_life', filename)), original);
  }
  assert.equal(await readFile(path.join(options.outputDir, '.nojekyll'), 'utf8'), '');
});

test('missing imported modules fail staging before replacing an existing artifact', async t => {
  const options = await fixture(t, { 'v41/game.js': null });
  await mkdir(options.outputDir);
  await writeFile(path.join(options.outputDir, 'keep.txt'), 'previous artifact');
  await assert.rejects(buildEchoPages(options), /Missing or invalid Pages asset: v41\/game\.js/);
  assert.equal(await readFile(path.join(options.outputDir, 'keep.txt'), 'utf8'), 'previous artifact');
});

test('preserves unrelated public applications without publishing backend source', async t => {
  const options = await fixture(t), repository = path.dirname(options.sourceDir);
  const publicFiles = {
    'sudoku.html': '<title>Sudoku</title><script src="./sudoku/app.js"></script>',
    'sudoku/app.js': 'const sudoku = 1;',
    'frontend/index.html': '<title>Factory frontend</title>',
    'dashboard/styles/main.css': 'body { color: red; }',
    'saas/frontend/index.html': '<title>SaaS</title>',
    'backend/dashboard/index.html': '<title>Dashboard</title>',
  };
  for (const [filename, contents] of Object.entries({ ...publicFiles, 'backend/private.py': 'PRIVATE_API = True' })) {
    await mkdir(path.dirname(path.join(repository, filename)), { recursive: true });
    await writeFile(path.join(repository, filename), contents);
  }
  const result = await buildEchoPages(options);
  assert.deepEqual(result.preserved, ['sudoku', 'frontend', 'dashboard', 'saas/frontend', 'backend/dashboard', 'sudoku.html']);
  for (const filename of Object.keys(publicFiles)) {
    assert.deepEqual(await readFile(path.join(options.outputDir, filename)), await readFile(path.join(repository, filename)));
  }
  await assert.rejects(readFile(path.join(options.outputDir, 'backend/private.py')), { code: 'ENOENT' });
});

test('root-relative asset URLs fail because GitHub project Pages uses a subpath', async t => {
  const options = await fixture(t, { 'v41.html': '<script src="/v41/app.js"></script>' });
  await assert.rejects(validateEntry(options.sourceDir), /project-relative Pages URLs/);
});

test('rejects a module import that escapes the published directory', async t => {
  const options = await fixture(t, { 'v41/app.js': 'import "../../private.js";' });
  await assert.rejects(validateEntry(options.sourceDir), /Asset escapes echo_life directory/);
});

test('rejects browser imports that require an absent package bundler', async t => {
  const options = await fixture(t, { 'v41/app.js': 'import "game-engine";' });
  await assert.rejects(validateEntry(options.sourceDir), /Browser modules require relative imports/);
});

test('checks dynamic imports and module-relative assets while allowing external URLs', async t => {
  const options = await fixture(t, {
    'v41/app.js': 'import("./game.js?v=41"); new URL("city.svg", import.meta.url);',
    'v41/styles.css': '@import "./base.css"; body { background: url(data:image/png;base64,AA==); }',
    'v41/base.css': '@import url("https://example.com/font.css");',
  });
  assert.deepEqual(await validateEntry(options.sourceDir), ['v41.html', 'v41/app.js', 'v41/base.css', 'v41/city.svg', 'v41/game.js', 'v41/styles.css']);
});

test('refuses to remove the source directory while staging', async t => {
  const options = await fixture(t);
  await assert.rejects(buildEchoPages({ ...options, outputDir: options.sourceDir }), /separate from the source/);
  await assert.rejects(buildEchoPages({ ...options, outputDir: path.dirname(options.sourceDir) }), /separate from the source/);
});

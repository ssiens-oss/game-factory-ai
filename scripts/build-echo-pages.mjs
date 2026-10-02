import { cp, lstat, mkdir, readFile, readdir, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const externalReference = /^(?:[a-z][a-z\d+.-]*:|\/\/|#)/i;

function references(contents, extension) {
  const found = [];
  if (extension === '.html') {
    for (const match of contents.matchAll(/\b(?:src|href)\s*=\s*["']([^"']+)["']/gi)) found.push(match[1]);
  }
  if (extension === '.js' || extension === '.mjs') {
    for (const match of contents.matchAll(/\b(?:import|export)\s+(?:[^;]*?\s+from\s+)?["']([^"']+)["']/g)) found.push(match[1]);
    for (const match of contents.matchAll(/\bimport\s*\(\s*["']([^"']+)["']\s*\)/g)) found.push(match[1]);
    for (const reference of found) {
      if (!externalReference.test(reference) && !reference.startsWith('.')) {
        throw new Error(`Browser modules require relative imports: ${reference}`);
      }
    }
    for (const match of contents.matchAll(/new\s+URL\s*\(\s*["']([^"']+)["']\s*,\s*import\.meta\.url\s*\)/g)) found.push(match[1]);
  }
  if (extension === '.css' || extension === '.html') {
    for (const match of contents.matchAll(/url\(\s*["']?([^\s"')]+)["']?\s*\)/gi)) found.push(match[1]);
    for (const match of contents.matchAll(/@import\s+["']([^"']+)["']/gi)) found.push(match[1]);
  }
  return found;
}

/** Validate the complete v41 document/module/style dependency graph before upload. */
export async function validateEntry(sourceDir, entry = 'v41.html') {
  const root = path.resolve(sourceDir);
  const visited = new Set();
  const pending = [path.resolve(root, entry)];
  while (pending.length) {
    const filename = pending.pop();
    if (visited.has(filename)) continue;
    if (filename !== root && !filename.startsWith(`${root}${path.sep}`)) {
      throw new Error(`Asset escapes echo_life directory: ${filename}`);
    }
    const stat = await lstat(filename).catch(() => null);
    if (!stat?.isFile()) throw new Error(`Missing or invalid Pages asset: ${path.relative(root, filename)}`);
    visited.add(filename);
    const extension = path.extname(filename).toLowerCase();
    if (!['.html', '.js', '.mjs', '.css'].includes(extension)) continue;
    const contents = await readFile(filename, 'utf8');
    for (const reference of references(contents, extension)) {
      if (externalReference.test(reference)) continue;
      if (reference.startsWith('/')) throw new Error(`Use project-relative Pages URLs in ${path.relative(root, filename)}: ${reference}`);
      const pathname = decodeURIComponent(reference.split(/[?#]/, 1)[0]);
      if (pathname) pending.push(path.resolve(path.dirname(filename), pathname));
    }
  }
  return [...visited].map(filename => path.relative(root, filename)).sort();
}

async function rejectSymlinks(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const filename = path.join(directory, entry.name);
    if (entry.isSymbolicLink()) throw new Error(`Pages assets must be regular files: ${filename}`);
    if (entry.isDirectory()) await rejectSymlinks(filename);
  }
}

function publicPath(repositoryDir, relative) {
  const root = path.resolve(repositoryDir), filename = path.resolve(root, relative);
  if (filename === root || !filename.startsWith(`${root}${path.sep}`)) throw new Error(`Invalid public Pages path: ${relative}`);
  return filename;
}

/** Preserve ECHO aliases and the repository's existing public web directories. */
export async function buildEchoPages({
  sourceDir = path.join(repoRoot, 'echo_life'),
  outputDir = path.join(repoRoot, '.pages-stage'),
  repositoryDir = path.dirname(sourceDir),
  preserveWebDirs = ['sudoku', 'frontend', 'dashboard', 'saas/frontend', 'backend/dashboard'],
  preserveWebFiles = ['sudoku.html'],
} = {}) {
  const source = path.resolve(sourceDir);
  const output = path.resolve(outputDir);
  if (source === output || source.startsWith(`${output}${path.sep}`) || output.startsWith(`${source}${path.sep}`)) {
    throw new Error('Pages output must be separate from the source directory');
  }
  await rejectSymlinks(source);
  let assets = await validateEntry(source);
  if (await lstat(path.join(source, 'v42.html')).catch(() => null)) assets = [...new Set([...assets, ...await validateEntry(source, 'v42.html')])].sort();
  if (await lstat(path.join(source, 'v43.html')).catch(() => null)) assets = [...new Set([...assets, ...await validateEntry(source, 'v43.html')])].sort();
  if (await lstat(path.join(source, 'v44.html')).catch(() => null)) assets = [...new Set([...assets, ...await validateEntry(source, 'v44.html')])].sort();
  if (await lstat(path.join(source, 'v45.html')).catch(() => null)) assets = [...new Set([...assets, ...await validateEntry(source, 'v45.html')])].sort();
  if (await lstat(path.join(source, 'v46.html')).catch(() => null)) assets = [...new Set([...assets, ...await validateEntry(source, 'v46.html')])].sort();
  const preserved = [];
  for (const relative of [...preserveWebDirs, ...preserveWebFiles]) {
    const filename = publicPath(repositoryDir, relative);
    const stat = await lstat(filename).catch(() => null);
    if (!stat) continue;
    const directory = preserveWebDirs.includes(relative);
    if (directory ? !stat.isDirectory() : !stat.isFile()) throw new Error(`Invalid public Pages asset: ${relative}`);
    if (directory) await rejectSymlinks(filename);
    if (filename === output || filename.startsWith(`${output}${path.sep}`) || output.startsWith(`${filename}${path.sep}`)) {
      throw new Error(`Public Pages source overlaps output: ${relative}`);
    }
    preserved.push({ filename, relative });
  }
  await rm(output, { recursive: true, force: true });
  await mkdir(output, { recursive: true });
  await cp(source, output, { recursive: true });
  await cp(source, path.join(output, 'echo_life'), { recursive: true });
  for (const { filename, relative } of preserved) {
    const target = path.join(output, relative);
    await mkdir(path.dirname(target), { recursive: true });
    await cp(filename, target, { recursive: true });
  }
  await writeFile(path.join(output, '.nojekyll'), '');
  return { outputDir: output, assets, preserved: preserved.map(item => item.relative) };
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const result = await buildEchoPages();
  console.log(`Staged ECHO//LIFE in ${result.outputDir}; validated ${result.assets.length} game files; preserved ${result.preserved.length} other public paths.`);
}

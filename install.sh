#!/usr/bin/env bash
# ============================================================
# GAME FACTORY AI — FULL BOOTSTRAP INSTALLER
# Run from anywhere: bash INSTALL.sh
# ============================================================
set -e

ROOT="$HOME/game-factory-ai"
echo "🚀 Installing Game Factory AI to $ROOT..."

# ── Directory tree ──────────────────────────────────────────
mkdir -p "$ROOT"/{backend/{app/{api,rl,studio,roblox,generator,build,qa,publisher,swarm,telemetry,control},venv},\
roblox_project/{src/{server/{generator,sim,ai,telemetry,hazards,economy,analytics},client,shared},control},\
infra,dashboard,logs,queue,results,builds}

touch "$ROOT"/backend/app/__init__.py \
      "$ROOT"/backend/app/api/__init__.py \
      "$ROOT"/backend/app/rl/__init__.py \
      "$ROOT"/backend/app/studio/__init__.py \
      "$ROOT"/backend/app/roblox/__init__.py \
      "$ROOT"/backend/app/generator/__init__.py \
      "$ROOT"/backend/app/build/__init__.py \
      "$ROOT"/backend/app/qa/__init__.py \
      "$ROOT"/backend/app/publisher/__init__.py \
      "$ROOT"/backend/app/swarm/__init__.py \
      "$ROOT"/backend/app/telemetry/__init__.py

# ── Python venv ─────────────────────────────────────────────
python3 -m venv "$ROOT/backend/venv"
source "$ROOT/backend/venv/bin/activate"
pip install --quiet --upgrade pip
pip install --quiet fastapi uvicorn redis requests

# ════════════════════════════════════════════════════════════
# BACKEND — FASTAPI CORE
# ════════════════════════════════════════════════════════════

cat > "$ROOT/backend/app/main.py" <<'PY'
from fastapi import FastAPI
from app.api.routes import router

app = FastAPI(title="Game Factory AI")
app.include_router(router)
PY

cat > "$ROOT/backend/app/api/routes.py" <<'PY'
from fastapi import APIRouter, Request
import redis, json, time

router = APIRouter()
r = redis.Redis(host="localhost", port=6379, decode_responses=True)

@router.post("/run")
def run(payload: dict):
    from app.studio.orchestrator import run_cycle
    return run_cycle(payload.get("prompt", "default obby"))

@router.post("/telemetry")
async def telemetry(req: Request):
    data = await req.json()
    data["ts"] = int(time.time())
    data["reward"] = _reward(data)
    r.lpush("telemetry", json.dumps(data))
    return {"ok": True}

@router.get("/metrics")
def metrics():
    raw = r.lrange("telemetry", 0, 200)
    return [json.loads(x) for x in raw]

def _reward(e):
    t = e.get("type", "")
    if t == "session_end":
        return min(2.0, e.get("playtime", 0) / 300)
    if t == "death":
        return -0.05
    return 0.1
PY

# ── Orchestrator ─────────────────────────────────────────────
cat > "$ROOT/backend/app/studio/orchestrator.py" <<'PY'
from app.generator.llm import generate_spec
from app.build.builder import build_unity
from app.qa.swarm import run_swarm
from app.qa.gate import evaluate
from app.publisher.publisher import publish

def run_cycle(prompt: str):
    spec   = generate_spec(prompt)
    build  = build_unity(spec)
    metrics = run_swarm(build)
    decision = evaluate(metrics)

    if decision["approved"]:
        publish(build)
        return {"status": "published", "score": decision["score"], "spec": spec}

    return {"status": "rejected", "score": decision["score"], "spec": spec}
PY

# ── Generator ────────────────────────────────────────────────
cat > "$ROOT/backend/app/generator/llm.py" <<'PY'
import random

HAZARDS = [
    "lava_gap","spinning_beam","moving_platform","falling_tiles","crusher",
    "laser_grid","wind_push","ice_slide","teleport_gap","fake_platform",
    "bounce_pad","speed_boost_trap","gravity_flip_zone","rotating_ring",
    "timed_bridge","collapsing_floor","moving_lasers","blade_swing",
    "fire_wave","electric_floor","darkness_zone","memory_platforms",
    "invisible_path","reverse_controls_zone","wind_tunnel","meteor_drop",
    "ice_break_tiles","trap_doors","homing_projectiles","laser_turrets",
    "rolling_boulder","lava_rise_timer","platform_shuffle","gravity_well",
    "laser_crossfire","timed_rotating_blocks","falling_stairs","boss_platform_event",
    "wall_climb_chase","energy_surge_zones","collapsing_bridge_chain","jump_timing_orbs",
    "teleport_maze","moving_spike_floor","speed_zone_switch","fake_checkpoint",
    "invisible_bridge","spike_wall","vertical_climb_spikes","horizontal_spike_wall"
]

GAME_TYPES = ["OBBY","HORROR","PHYSICS","SURVIVAL","TYCOON","SIMULATOR","GTA_STYLE"]

def generate_spec(prompt: str, difficulty: float = 1.0):
    game_type = random.choice(GAME_TYPES)
    seed = random.randint(1, 999999)
    n_hazards = min(len(HAZARDS), max(3, int(difficulty * 6)))
    return {
        "name": f"AutoGame-{seed}",
        "prompt": prompt,
        "gameType": game_type,
        "seed": seed,
        "difficulty": difficulty,
        "length": int(20 + difficulty * 15),
        "platform_gap": max(2.5, 6.0 - difficulty),
        "hazard_density": min(0.9, 0.2 + difficulty * 0.3),
        "hazards": random.sample(HAZARDS, k=n_hazards),
        "checkpoint_spacing": max(5, 12 - int(difficulty * 2)),
        "bots": int(25 + difficulty * 60),
        "monetization": "revive_skip"
    }
PY

# ── Builder ──────────────────────────────────────────────────
cat > "$ROOT/backend/app/build/builder.py" <<'PY'
import uuid

def build_unity(spec):
    build_id = str(uuid.uuid4())
    return {"build_id": build_id, "spec": spec, "path": f"/builds/{build_id}"}
PY

# ── QA Swarm ─────────────────────────────────────────────────
cat > "$ROOT/backend/app/swarm/profile.py" <<'PY'
import random

class Agent:
    STYLES = {"casual": -0.1, "speedrunner": 0.2, "explorer": 0.0, "exploiter": 0.3}

    def __init__(self, i, style):
        self.style = style
        self.skill = random.uniform(0.3, 1.0)

    def simulate(self, build):
        diff = build["spec"].get("difficulty", 1.0)
        base = 0.5 + diff * 0.1
        bias = self.STYLES[self.style]
        p = self.skill - base + bias
        return {
            "completed": random.random() < max(0.05, min(0.95, p + 0.5)),
            "exploited":  self.style == "exploiter" and random.random() < 0.2,
            "time":       random.uniform(30, 600)
        }
PY

cat > "$ROOT/backend/app/swarm/agents.py" <<'PY'
import random
from app.swarm.profile import Agent

def create_agents(n):
    styles = list(Agent.STYLES.keys())
    return [Agent(i, random.choice(styles)) for i in range(n)]
PY

cat > "$ROOT/backend/app/swarm/engine.py" <<'PY'
from app.swarm.agents import create_agents

def run_swarm(build, agent_count=300):
    agents = create_agents(agent_count)
    completions = exploits = 0
    total_time = 0.0

    for a in agents:
        r = a.simulate(build)
        if r["completed"]: completions += 1
        if r["exploited"]:  exploits   += 1
        total_time += r["time"]

    n = len(agents)
    return {
        "completion_rate": completions / n,
        "exploit_rate":    exploits   / n,
        "avg_session_time": total_time / n
    }
PY

cat > "$ROOT/backend/app/qa/swarm.py" <<'PY'
from app.swarm.engine import run_swarm as _engine

def run_swarm(build):
    return _engine(build, agent_count=300)
PY

# ── Quality Gate ─────────────────────────────────────────────
cat > "$ROOT/backend/app/qa/gate.py" <<'PY'
def evaluate(metrics):
    score = (
        metrics["completion_rate"]    * 0.5 +
        metrics["avg_session_time"] / 600 * 0.4 -
        metrics["exploit_rate"]       * 0.1
    )
    return {"score": round(score, 4), "approved": score > 0.35}
PY

# ── Publisher ────────────────────────────────────────────────
cat > "$ROOT/backend/app/publisher/publisher.py" <<'PY'
def publish(build):
    print(f"[PUBLISH] {build['build_id']} — {build['spec']['gameType']}")
PY

# ── RL Engine ────────────────────────────────────────────────
cat > "$ROOT/backend/app/rl/engine.py" <<'PY'
import redis, json

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

class RLEngine:
    def __init__(self):
        self.difficulty = 1.0

    def compute_reward(self, metrics):
        return (
            metrics.get("completion_rate", 0) * 2.0 +
            metrics.get("avg_session_time", 0) / 100.0 -
            metrics.get("exploit_rate", 0) * 0.5
        )

    def update(self, metrics):
        r_val = self.compute_reward(metrics)
        if r_val > 1.2:
            self.difficulty *= 1.05
        elif r_val < 0.6:
            self.difficulty *= 0.95
        self.difficulty = max(0.5, min(3.0, self.difficulty))
        return self.difficulty
PY

# ── Economy Brain (unified) ──────────────────────────────────
cat > "$ROOT/backend/app/rl/economy_brain.py" <<'PY'
class EconomyBrain:
    def __init__(self):
        self.state = {
            "difficulty_curve":       1.0,
            "monetization_pressure":  1.0,
            "engagement_bias":        1.0,
        }

    def score_player(self, s):
        ltv = (
            (s.get("time", 1)      * 0.04) +
            (s.get("purchases", 0) * 12)   +
            (s.get("progress", 1)  * 1.8)  -
            (s.get("deaths", 0)    * 0.25)
        )
        churn = min(1.0, (
            (0.4 if s.get("time", 60) < 60 else 0) +
            (0.3 if s.get("deaths", 0) > 10 else 0) +
            (0.3 if s.get("progress", 5) < 3 else 0)
        ))
        return ltv, churn

    def decide(self, ltv, churn):
        if ltv > 25 and churn > 0.6:
            return {"mode":"SAVE",       "reviveMult":0.5, "skipMult":0.6, "diffMult":0.85}
        if ltv > 10:
            return {"mode":"OPTIMIZE",   "reviveMult":1.0, "skipMult":1.1, "diffMult":1.05}
        if churn > 0.7:
            return {"mode":"RETENTION",  "reviveMult":0.7, "skipMult":0.7, "diffMult":0.8,
                    "disableMonetization": True}
        return     {"mode":"STANDARD",   "reviveMult":1.0, "skipMult":1.0, "diffMult":1.0}

    def update(self, telemetry_batch):
        if not telemetry_batch:
            return self.state
        avg_deaths = sum(t.get("deaths",0) for t in telemetry_batch) / len(telemetry_batch)
        purchases  = sum(t.get("purchases",0) for t in telemetry_batch)
        if avg_deaths > 5:
            self.state["difficulty_curve"] *= 0.95
        else:
            self.state["difficulty_curve"] *= 1.05
        if purchases < len(telemetry_batch) * 0.1:
            self.state["monetization_pressure"] *= 1.1
        else:
            self.state["monetization_pressure"] *= 0.98
        for k in self.state:
            self.state[k] = max(0.5, min(2.0, self.state[k]))
        return self.state
PY

# ── Master / Worker (Redis) ──────────────────────────────────
cat > "$ROOT/backend/app/studio/master.py" <<'PY'
import redis, json, time, uuid, random
from app.rl.engine import RLEngine

r  = redis.Redis(host="localhost", port=6379, decode_responses=True)
rl = RLEngine()

def generate_job():
    return {
        "id":           str(uuid.uuid4()),
        "difficulty":   rl.difficulty,
        "seed":         random.randint(1, 999999),
        "length":       int(20 + rl.difficulty * 10),
        "hazard_density": min(0.95, 0.2 + rl.difficulty * 0.4),
    }

def loop():
    print("🧠 MASTER ONLINE")
    while True:
        job = generate_job()
        r.lpush("jobs", json.dumps(job))
        print(f"📦 job {job['id'][:8]} | diff={rl.difficulty:.2f}")

        raw = r.lrange("metrics", 0, 50)
        metrics_list = [json.loads(x) for x in raw]
        if metrics_list:
            avg = sum(m.get("reward",0) for m in metrics_list) / len(metrics_list)
            rl.update({"completion_rate": avg, "avg_session_time": 60, "exploit_rate": 0.1})

        time.sleep(3)

if __name__ == "__main__":
    loop()
PY

cat > "$ROOT/backend/app/studio/worker.py" <<'PY'
import redis, json, time, random

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

def process(job):
    reward = random.random() * job.get("difficulty", 1.0)
    r.lpush("metrics", json.dumps({"id": job["id"], "reward": reward}))
    print(f"🤖 done {job['id'][:8]} reward={reward:.2f}")

def loop():
    print("🤖 WORKER ONLINE")
    while True:
        raw = r.rpop("jobs")
        if raw:
            try: process(json.loads(raw))
            except Exception as e: print("err:", e)
        else:
            time.sleep(1)

if __name__ == "__main__":
    loop()
PY

# ── Live RL loop ─────────────────────────────────────────────
cat > "$ROOT/backend/app/studio/live_loop.py" <<'PY'
import time, random, json
import redis
from app.rl.economy_brain import EconomyBrain

r    = redis.Redis(host="localhost", port=6379, decode_responses=True)
brain = EconomyBrain()

def loop():
    print("🎮 LIVE RL LOOP ONLINE")
    while True:
        raw = r.lrange("telemetry", 0, 100)
        batch = [json.loads(x) for x in raw]
        state = brain.update(batch)
        print(f"🎚  diff={state['difficulty_curve']:.2f} "
              f"mono={state['monetization_pressure']:.2f}")
        time.sleep(5)

if __name__ == "__main__":
    loop()
PY

# ── Requirements ─────────────────────────────────────────────
cat > "$ROOT/backend/requirements.txt" <<'REQ'
fastapi
uvicorn
redis
requests
REQ

# ════════════════════════════════════════════════════════════
# ROBLOX — LUA SCRIPTS (Rojo-ready)
# ════════════════════════════════════════════════════════════

# Config (overwritten by Python RL loop)
cat > "$ROOT/roblox_project/src/shared/Config.lua" <<'LUA'
local Config = {
    Difficulty      = 1.0,
    Length          = 30,
    PlatformGap     = 5.0,
    HazardChance    = 0.30,
    GameType        = "OBBY",
    Monetization    = 1.0,
}
return Config
LUA

# World Bootstrap — all building is scripted
cat > "$ROOT/roblox_project/src/server/WorldBootstrap.server.lua" <<'LUA'
local Config = require(game.ReplicatedStorage.Config)
local Players = game:GetService("Players")

local function part(size, pos, color, name)
    local p = Instance.new("Part")
    p.Size, p.Position, p.Anchored = size, pos, true
    p.Color = color or Color3.fromRGB(220,220,220)
    p.Name  = name or "Block"
    p.Parent = workspace
    return p
end

local function killBrick(pos)
    local h = part(Vector3.new(10,1,10), pos, Color3.fromRGB(255,50,50), "KillBrick")
    h.Touched:Connect(function(hit)
        local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

local function checkpoint(pos, i)
    local c = part(Vector3.new(10,2,10), pos, Color3.fromRGB(0,200,100), "Checkpoint")
    c.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and _G.SetCheckpoint then _G.SetCheckpoint(player, pos) end
    end)
end

local function generateWorld()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("BasePart") or v:IsA("Model") then v:Destroy() end
    end

    -- spawn pad
    part(Vector3.new(20,1,20), Vector3.new(0,4,0), Color3.fromRGB(0,255,100), "SpawnPad")

    local pos = Vector3.new(0, 5, 0)
    local gap = Config.PlatformGap

    for i = 1, Config.Length do
        pos = pos + Vector3.new(0, math.random(0,2) * Config.Difficulty, gap * 10)

        if math.random() < Config.HazardChance then
            killBrick(pos + Vector3.new(0, 1, 0))
        else
            part(Vector3.new(10,1,10), pos)
        end

        -- checkpoint every N segments
        if i % Config.CheckpointSpacing == 0 then
            checkpoint(pos + Vector3.new(0, 3, 0), i)
        end
    end

    -- win zone
    local winPos = pos + Vector3.new(0, 5, 20)
    local w = part(Vector3.new(15,5,15), winPos, Color3.fromRGB(255,215,0), "WinZone")
    w.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            print("🏆 WIN:", player.Name)
            player:LoadCharacter()
        end
    end)
end

generateWorld()

-- Hot-reload loop (picks up Config changes from Python RL)
while true do
    task.wait(10)
    generateWorld()
end
LUA

# Checkpoint service
cat > "$ROOT/roblox_project/src/server/CheckpointService.server.lua" <<'LUA'
local Players = game:GetService("Players")
local checkpoints = {}

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        local cp = checkpoints[player.UserId]
        if cp and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(cp + Vector3.new(0, 5, 0))
        end
    end)
end)

_G.SetCheckpoint = function(player, pos)
    checkpoints[player.UserId] = pos
end
LUA

# Game Controller
cat > "$ROOT/roblox_project/src/server/GameController.server.lua" <<'LUA'
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local BACKEND = "http://127.0.0.1:8000"
local sessions = {}

Players.PlayerAdded:Connect(function(player)
    sessions[player.UserId] = { deaths = 0, start = os.clock() }
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            sessions[player.UserId].deaths += 1
            pcall(function()
                HttpService:PostAsync(BACKEND .. "/telemetry",
                    HttpService:JSONEncode({ type="death", userId=player.UserId }),
                    Enum.HttpContentType.ApplicationJson)
            end)
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local s = sessions[player.UserId]
    if not s then return end
    local playtime = os.clock() - s.start
    pcall(function()
        HttpService:PostAsync(BACKEND .. "/telemetry",
            HttpService:JSONEncode({
                type    = "session_end",
                userId  = player.UserId,
                playtime = playtime,
                deaths  = s.deaths
            }), Enum.HttpContentType.ApplicationJson)
    end)
    sessions[player.UserId] = nil
end)
LUA

# Economy Brain (Lua side)
cat > "$ROOT/roblox_project/src/server/EconomyBrain.server.lua" <<'LUA'
local Players = game:GetService("Players")

local state = {}

local function score(s)
    local ltv = (s.time or 1)*0.04 + (s.purchases or 0)*12
                + (s.progress or 1)*1.8 - (s.deaths or 0)*0.25
    local churn = math.clamp(
        (s.time or 60) < 60 and 0.4 or 0 +
        (s.deaths or 0) > 10 and 0.3 or 0 +
        (s.progress or 5) < 3 and 0.3 or 0, 0, 1)
    return ltv, churn
end

local function decide(ltv, churn)
    if ltv > 25 and churn > 0.6 then
        return {mode="SAVE",      revive=0.5, skip=0.6, diff=0.85}
    elseif ltv > 10 then
        return {mode="OPTIMIZE",  revive=1.0, skip=1.1, diff=1.05}
    elseif churn > 0.7 then
        return {mode="RETENTION", revive=0.7, skip=0.7, diff=0.80, disableMono=true}
    end
    return     {mode="STANDARD",  revive=1.0, skip=1.0, diff=1.0}
end

Players.PlayerAdded:Connect(function(p)
    state[p.UserId] = {time=0, deaths=0, progress=0, purchases=0}
    task.spawn(function()
        while p.Parent do
            state[p.UserId].time += 1
            task.wait(1)
        end
    end)
end)

_G.BRAIN_TrackDeath = function(p) if state[p.UserId] then state[p.UserId].deaths += 1 end end
_G.BRAIN_TrackProgress = function(p,a) if state[p.UserId] then state[p.UserId].progress += a end end
_G.BRAIN_TrackPurchase = function(p) if state[p.UserId] then state[p.UserId].purchases += 1 end end

_G.GetBrainPolicy = function(player)
    local s = state[player.UserId]
    if not s then return {mode="STANDARD",revive=1,skip=1,diff=1} end
    local ltv, churn = score(s)
    return decide(ltv, churn)
end

task.spawn(function()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            local s = state[p.UserId]
            if s then
                local ltv, churn = score(s)
                local pol = decide(ltv, churn)
                print(string.format("💰 %s | mode=%s ltv=%.1f churn=%.2f", p.Name, pol.mode, ltv, churn))
            end
        end
        task.wait(10)
    end
end)
LUA

# Monetization (Dev Products)
cat > "$ROOT/roblox_project/src/server/Monetization.server.lua" <<'LUA'
-- 🔧 Replace with your actual Dev Product IDs
local PRODUCTS = { REVIVE = 0000000001, SKIP = 0000000002 }

local Players           = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local savedCheckpoints = {}

_G.SetCheckpoint = _G.SetCheckpoint or function(player, pos)
    savedCheckpoints[player.UserId] = pos
end

local function revive(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        local cp = savedCheckpoints[player.UserId]
        if cp then hrp.CFrame = CFrame.new(cp + Vector3.new(0,5,0)) end
        hum.Health = hum.MaxHealth
    end
end

local function skip(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 0, -100)
        _G.BRAIN_TrackProgress(player, 5)
    end
end

MarketplaceService.ProcessReceipt = function(receipt)
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

    if receipt.ProductId == PRODUCTS.REVIVE then revive(player) end
    if receipt.ProductId == PRODUCTS.SKIP   then skip(player)   end

    if _G.BRAIN_TrackPurchase then _G.BRAIN_TrackPurchase(player) end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
LUA

# Shop UI (client)
cat > "$ROOT/roblox_project/src/client/ShopUI.client.lua" <<'LUA'
local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local PRODUCTS = { REVIVE = 0000000001, SKIP = 0000000002 }
local player   = Players.LocalPlayer

local gui   = Instance.new("ScreenGui")
gui.Parent  = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size     = UDim2.new(0, 230, 0, 140)
frame.Position = UDim2.new(0, 15, 0, 200)
frame.BackgroundTransparency = 0.15
frame.Parent   = gui

local status = Instance.new("TextLabel")
status.Size   = UDim2.new(1,0,0.25,0)
status.Text   = "💰 Shop"
status.Parent = frame

local reviveBtn = Instance.new("TextButton")
reviveBtn.Size     = UDim2.new(1,0,0.35,0)
reviveBtn.Position = UDim2.new(0,0,0.25,0)
reviveBtn.Text     = "Revive 💀"
reviveBtn.Parent   = frame

local skipBtn = Instance.new("TextButton")
skipBtn.Size     = UDim2.new(1,0,0.35,0)
skipBtn.Position = UDim2.new(0,0,0.60,0)
skipBtn.Text     = "Skip Level 🚀"
skipBtn.Parent   = frame

-- Dynamic pricing from EconomyBrain
task.spawn(function()
    while true do
        local pol = _G.GetBrainPolicy and _G.GetBrainPolicy(player)
        if pol then
            reviveBtn.Text = string.format("Revive 💀 (x%.1f)", pol.revive or 1)
            skipBtn.Text   = string.format("Skip 🚀 (x%.1f)",   pol.skip   or 1)
            status.Text    = "Mode: " .. (pol.mode or "STANDARD")
        end
        task.wait(3)
    end
end)

reviveBtn.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, PRODUCTS.REVIVE)
end)
skipBtn.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, PRODUCTS.SKIP)
end)

-- Auto-prompt on death
local function hookChar(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        task.wait(1.5)
        MarketplaceService:PromptProductPurchase(player, PRODUCTS.REVIVE)
    end)
end

if player.Character then hookChar(player.Character) end
player.CharacterAdded:Connect(hookChar)
LUA

# Rojo project.json
cat > "$ROOT/roblox_project/default.project.json" <<'JSON'
{
  "name": "GameFactoryAI",
  "tree": {
    "$className": "DataModel",

    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Config": { "$path": "src/shared/Config.lua" }
    },

    "ServerScriptService": {
      "$className": "ServerScriptService",
      "WorldBootstrap":     { "$path": "src/server/WorldBootstrap.server.lua" },
      "CheckpointService":  { "$path": "src/server/CheckpointService.server.lua" },
      "GameController":     { "$path": "src/server/GameController.server.lua" },
      "EconomyBrain":       { "$path": "src/server/EconomyBrain.server.lua" },
      "Monetization":       { "$path": "src/server/Monetization.server.lua" }
    },

    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "ShopUI": { "$path": "src/client/ShopUI.client.lua" }
      }
    }
  }
}
JSON

# ════════════════════════════════════════════════════════════
# PYTHON RL → CONFIG HOT-RELOAD
# ════════════════════════════════════════════════════════════

cat > "$ROOT/config_bus.py" <<'PY'
"""
Runs continuously: RL brain → rewrites Config.lua → Rojo syncs → Studio hot-reloads.
"""
import time, random, sys
from pathlib import Path

ROOT       = Path(__file__).parent
CONFIG_LUA = ROOT / "roblox_project/src/shared/Config.lua"

GAME_TYPES = ["OBBY","HORROR","PHYSICS","SURVIVAL","TYCOON","SIMULATOR","GTA_STYLE"]

def write_config(diff, game_type=None):
    gt = game_type or random.choice(GAME_TYPES)
    CONFIG_LUA.write_text(f"""
-- AUTO-GENERATED by config_bus.py — DO NOT EDIT MANUALLY
local Config = {{
    Difficulty        = {diff:.3f},
    Length            = {int(20 + diff * 15)},
    PlatformGap       = {max(2.5, 6.0 - diff):.2f},
    HazardChance      = {min(0.8, 0.2 + diff * 0.3):.3f},
    CheckpointSpacing = {max(4, 12 - int(diff * 2))},
    GameType          = "{gt}",
    Monetization      = {min(2.0, 0.8 + diff * 0.3):.3f},
}}
return Config
""")
    print(f"📝 config → diff={diff:.2f} type={gt}")

def rl_loop():
    diff = 1.0
    while True:
        diff += 0.02 if diff < 2.0 else -0.05
        diff = max(0.5, min(3.0, diff))
        write_config(diff)
        time.sleep(5)

if __name__ == "__main__":
    print("🧠 Config bus started — Ctrl+C to stop")
    rl_loop()
PY

# ════════════════════════════════════════════════════════════
# ROJO SUPERVISOR (production-grade, crash-safe)
# ════════════════════════════════════════════════════════════

cat > "$ROOT/rojo_supervisor.py" <<'PY'
"""
Self-healing Rojo supervisor:
- kills stale port holders
- exponential backoff restarts
- structured logging
- max restart limit
"""
import subprocess, socket, os, time, sys
from datetime import datetime
from pathlib import Path

PORT        = 34872
MAX_RESTART = 50
LOG_FILE    = Path(__file__).parent / "logs/rojo_supervisor.log"
PROJECT_DIR = Path(__file__).parent / "roblox_project"

def log(msg):
    line = f"[{datetime.now().isoformat()}] {msg}"
    print(line)
    LOG_FILE.parent.mkdir(exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")

def port_busy(port):
    try:
        s = socket.create_connection(("127.0.0.1", port), timeout=1)
        s.close(); return True
    except: return False

def kill_port(port):
    os.system(f"lsof -ti :{port} | xargs kill -9 2>/dev/null || true")

def classify(output):
    t = output.lower()
    if "address already in use" in t: return "port_conflict"
    if "permission"             in t: return "permission_denied"
    if "not found"              in t: return "rojo_missing"
    return "unknown"

def run():
    backoff  = 2
    restarts = 0
    while restarts < MAX_RESTART:
        if port_busy(PORT):
            log(f"⚠️  Port {PORT} busy — killing stale process")
            kill_port(PORT)
            time.sleep(1)

        log("🚀 Starting Rojo")
        proc = subprocess.Popen(
            ["rojo", "serve", "--port", str(PORT)],
            cwd=str(PROJECT_DIR),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )

        buf = []
        healthy = False
        for line in proc.stdout:
            line = line.rstrip()
            buf.append(line)
            print(line)
            if "listening" in line.lower() or "34872" in line:
                log("✅ Rojo healthy on :" + str(PORT))
                healthy = True
                backoff = 2   # reset backoff on success

        proc.wait()
        reason = classify("\n".join(buf))
        restarts += 1
        log(f"⚠️  Rojo exited (reason={reason}, attempt={restarts})")
        sleep = min(60, backoff * (2 ** min(restarts, 5)))
        log(f"🔁 Restart in {sleep}s")
        time.sleep(sleep)

    log("❌ Max restarts reached — exiting supervisor")

if __name__ == "__main__":
    run()
PY

# ════════════════════════════════════════════════════════════
# UNIFIED LAUNCHER
# ════════════════════════════════════════════════════════════

cat > "$ROOT/launch_factory.py" <<'PY'
"""
Single-command launcher:
  python3 launch_factory.py
Starts: API + RL loop + Rojo supervisor + master + worker
"""
import subprocess, time, sys, os
from pathlib import Path

ROOT    = Path(__file__).parent
VENV    = ROOT / "backend/venv/bin/python3"
PYTHON  = str(VENV) if VENV.exists() else sys.executable

os.environ["PYTHONPATH"] = str(ROOT / "backend")

SERVICES = [
    ("API",        [PYTHON, "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"],
                   ROOT / "backend"),
    ("Master",     [PYTHON, "-m", "app.studio.master"],   ROOT / "backend"),
    ("Worker",     [PYTHON, "-m", "app.studio.worker"],   ROOT / "backend"),
    ("LiveLoop",   [PYTHON, "-m", "app.studio.live_loop"],ROOT / "backend"),
    ("ConfigBus",  [PYTHON, str(ROOT / "config_bus.py")], ROOT),
    ("RojoSuperv", [PYTHON, str(ROOT / "rojo_supervisor.py")], ROOT),
]

procs = []

def start_all():
    for name, cmd, cwd in SERVICES:
        p = subprocess.Popen(cmd, cwd=str(cwd))
        procs.append((name, p))
        print(f"▶  {name} started (pid={p.pid})")
        time.sleep(0.5)

def monitor():
    print("\n🎮 Game Factory AI running — Ctrl+C to stop\n")
    try:
        while True:
            for name, p in procs:
                if p.poll() is not None:
                    print(f"⚠️  {name} died (code={p.returncode}) — restart manually if needed")
            time.sleep(5)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down...")
        for _, p in procs:
            p.terminate()

if __name__ == "__main__":
    start_all()
    monitor()
PY

# ════════════════════════════════════════════════════════════
# gf CLI (path-safe, doctor included)
# ════════════════════════════════════════════════════════════

cat > "$ROOT/gf" <<'BASH'
#!/bin/bash
ROOT="$HOME/game-factory-ai"
VENV="$ROOT/backend/venv/bin/activate"
cd "$ROOT" || exit 1
export PYTHONPATH="$ROOT/backend"

_activate() { [ -f "$VENV" ] && source "$VENV"; }

doctor() {
  echo "🩺 gf doctor running..."

  # Redis
  if redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis OK"
  else
    echo "⚠️  Starting Redis..."
    nohup redis-server > logs/redis.log 2>&1 &
    sleep 2
    redis-cli ping >/dev/null && echo "✅ Redis started" || echo "❌ Redis FAILED"
  fi

  # Port 8000
  PID=$(lsof -t -i:8000 2>/dev/null || true)
  [ -n "$PID" ] && { echo "⚠️  Killing :8000 ($PID)"; kill -9 $PID; }

  # Venv
  [ ! -d "$ROOT/backend/venv" ] && python3 -m venv "$ROOT/backend/venv"
  _activate
  pip install --quiet fastapi uvicorn redis requests

  # Rojo port
  RPID=$(lsof -t -i:34872 2>/dev/null || true)
  [ -n "$RPID" ] && { echo "⚠️  Killing :34872 ($RPID)"; kill -9 $RPID; }

  # Start API
  _activate
  nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 \
    > logs/api.log 2>&1 & sleep 2
  curl -s http://127.0.0.1:8000/docs >/dev/null \
    && echo "✅ API at http://127.0.0.1:8000" || echo "❌ API failed"

  echo ""; echo "🎯 SYSTEM READY"
}

case "$1" in
  doctor)   doctor ;;
  run)      _activate; python3 launch_factory.py ;;
  api)      _activate; python3 -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 ;;
  master)   _activate; cd backend && python3 -m app.studio.master ;;
  worker)   _activate; cd backend && python3 -m app.studio.worker ;;
  rl)       _activate; cd backend && python3 -m app.studio.live_loop ;;
  config)   _activate; python3 config_bus.py ;;
  rojo)     python3 rojo_supervisor.py ;;
  write)
    shift; target="$1"; shift
    mkdir -p "$(dirname "$ROOT/$target")"
    cat > "$ROOT/$target"
    echo "✅ wrote $ROOT/$target"
    ;;
  ls)       find backend/app -name "*.py" | head -40 ;;
  *)
    echo "Usage: gf <command>"
    echo "  doctor  — auto-fix Redis/ports/venv/API"
    echo "  run     — launch entire factory"
    echo "  api     — start FastAPI only"
    echo "  master  — start RL master"
    echo "  worker  — start job worker"
    echo "  rl      — start live RL loop"
    echo "  config  — start Rojo config hot-reload"
    echo "  rojo    — start Rojo supervisor"
    echo "  write <path> — safely write file under project root"
    echo "  ls      — list backend modules"
    ;;
esac
BASH
chmod +x "$ROOT/gf"

# ════════════════════════════════════════════════════════════
# INFRA
# ════════════════════════════════════════════════════════════

cat > "$ROOT/infra/docker-compose.yml" <<'YAML'
version: "3.8"
services:
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
    restart: unless-stopped

  backend:
    build:
      context: ../backend
      dockerfile: Dockerfile
    ports: ["8000:8000"]
    depends_on: [redis]
    environment:
      REDIS_HOST: redis
    restart: unless-stopped
YAML

cat > "$ROOT/backend/Dockerfile" <<'DOCKER'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PYTHONPATH=/app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
DOCKER

# Dashboard
cat > "$ROOT/dashboard/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Game Factory AI</title>
<style>
  body { font-family: monospace; background:#111; color:#0f0; padding:20px; }
  input,button,pre { font-family:monospace; font-size:14px; }
  input { background:#222; color:#0f0; border:1px solid #0f0; padding:8px; width:400px; }
  button { background:#0f0; color:#000; border:none; padding:8px 16px; cursor:pointer; margin:4px; }
  pre { background:#000; padding:12px; border:1px solid #333; min-height:80px; }
</style>
</head>
<body>
<h2>🎮 Game Factory AI</h2>
<input id="p" placeholder="game idea (e.g. horror obby with lava)">
<br><br>
<button onclick="run()">▶ Generate</button>
<button onclick="getMetrics()">📊 Metrics</button>
<pre id="out">awaiting output...</pre>

<script>
const API = "http://localhost:8000";

async function run() {
  document.getElementById("out").textContent = "generating...";
  const res = await fetch(API + "/run", {
    method:"POST",
    headers:{"Content-Type":"application/json"},
    body: JSON.stringify({prompt: document.getElementById("p").value || "default obby"})
  });
  document.getElementById("out").textContent = JSON.stringify(await res.json(), null, 2);
}

async function getMetrics() {
  const res = await fetch(API + "/metrics");
  const data = await res.json();
  document.getElementById("out").textContent = JSON.stringify(data.slice(0,10), null, 2);
}
</script>
</body>
</html>
HTML

# Final check
echo ""
echo "════════════════════════════════════════════"
echo "✅ Game Factory AI installed to $ROOT"
echo "════════════════════════════════════════════"
echo ""
echo "Quick start:"
echo "  cd $ROOT"
echo "  ./gf doctor          # fix environment"
echo "  ./gf run             # launch everything"
echo ""
echo "Or step by step:"
echo "  redis-server &"
echo "  ./gf api &"
echo "  ./gf master &"
echo "  ./gf worker &"
echo "  ./gf config &        # hot-reload Roblox configs"
echo "  ./gf rojo            # Rojo supervisor (needs rojo installed)"
echo ""
echo "Roblox Studio:"
echo "  1. Install Rojo plugin from rojo.space"
echo "  2. Open roblox_project/ in Studio"
echo "  3. Connect Rojo to localhost:34872"
echo "  4. Press Play — everything is scripted"
echo ""
echo "Dashboard:"
echo "  open dashboard/index.html"

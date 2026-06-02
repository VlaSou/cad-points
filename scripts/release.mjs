import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..");
const buildScript = path.join(repoRoot, "scripts", "build_release.py");
const args = process.argv.slice(2);
const checkOnly = args.includes("--check");

const result = spawnSync("py", ["-3", buildScript, ...(checkOnly ? ["--check"] : [])], {
  cwd: repoRoot,
  stdio: "inherit",
  shell: false,
});

if (result.error) {
  throw result.error;
}

process.exit(result.status ?? 1);

// Stand-in for a real bundler: copies the sample page into ./build.
import { cpSync, mkdirSync, rmSync } from "node:fs";

rmSync("build", { recursive: true, force: true });
mkdirSync("build", { recursive: true });
cpSync("src/index.html", "build/index.html");
console.log("built ./build");

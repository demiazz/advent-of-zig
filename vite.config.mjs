import path from "node:path";

import reactPlugin from "@vitejs/plugin-react";
import { vanillaExtractPlugin } from "@vanilla-extract/vite-plugin";

const rootDir = import.meta.dirname;

export default {
  plugins: [reactPlugin(), vanillaExtractPlugin()],

  resolve: {
    alias: [
      {
        find: "advent-of-zig.wasm?url",
        replacement: `${path.join(rootDir, "zig-out/bin/advent-of-zig.wasm?url")}`,
      },
      {
        find: "@",
        replacement: path.join(rootDir, "./web/"),
      },
    ],
  },
};

console.log(path.join(rootDir, "./web/$1"));

// "@*": ["./web/*"],

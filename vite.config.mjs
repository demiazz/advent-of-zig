import path from "node:path";

import preactPlugin from "@preact/preset-vite";
import { vanillaExtractPlugin } from "@vanilla-extract/vite-plugin";

const rootDir = import.meta.dirname;

export default {
  base: "./",

  build: {
    assetsInlineLimit: 0,
  },

  plugins: [
    preactPlugin({
      babel: false,
      reactAliasesEnabled: false,
    }),
    vanillaExtractPlugin(),
  ],

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

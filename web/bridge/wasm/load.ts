import wasmUrl from "advent-of-zig.wasm?url";

import { parseString } from "./helpers";

type WasmExports = {
  getAvailable: () => number;
  freeAvailable: (ptr: number) => void;

  allocateString: (len: number) => number;
  freeString: (ptr: number) => void;

  solve: (year: number, day: number, part: number, inputPtr: number) => number;

  memory: WebAssembly.Memory;
};

type WasmModule = {
  exports: WasmExports;
};

export async function load(): Promise<WasmExports> {
  const module = await WebAssembly.compileStreaming(fetch(wasmUrl));

  const { exports }: WasmModule = (await WebAssembly.instantiate(module, {
    env: {
      onLog(level: number, ptr: number) {
        const message = parseString(exports.memory, ptr);

        switch (level) {
          case 0: {
            console.error(message);

            break;
          }
          case 1: {
            console.warn(message);

            break;
          }
          case 2: {
            console.info(message);

            break;
          }
          case 3: {
            console.debug(message);

            break;
          }
        }
      },
    },
  })) as unknown as WasmModule;

  return exports;
}

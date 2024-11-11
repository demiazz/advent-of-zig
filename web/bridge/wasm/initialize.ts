import { Solutions } from "@types";

import { load } from "./load";
import {
  parseAvailableItems,
  parseSolutions,
  parseString,
  transferString,
} from "./helpers";

type WasmAPI = {
  getAvailable(): Solutions;
  solve(year: number, day: number, part: number, input: string): string;
};

export async function initialize(): Promise<WasmAPI> {
  const exports = await load();

  function getAvailable(): Solutions {
    const ptr = exports.getAvailable();
    const items = parseAvailableItems(exports.memory, ptr);
    const solutions = parseSolutions(items);

    exports.freeAvailable(ptr);

    return solutions;
  }

  function solve(
    year: number,
    day: number,
    part: number,
    input: string
  ): string {
    const inputPtr = transferString(
      exports.memory,
      exports.allocateString,
      input
    );
    const answerPtr = exports.solve(year, day, part, inputPtr);
    const answer = parseString(exports.memory, answerPtr);

    exports.freeString(answerPtr);

    return answer;
  }

  return { getAvailable, solve };
}

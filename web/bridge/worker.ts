import { Answer } from "@/types";

import { MainEvent, WorkerEvent, ReadyEvent } from "./types";
import { initialize } from "./wasm";

function sendMessage(message: ReadyEvent | MainEvent) {
  self.postMessage(message);
}

initialize()
  .then(({ getAvailable, solve }) => {
    self.postMessage({ type: "ready" });

    function toAnswer(
      year: number,
      day: number,
      part: number,
      input: string
    ): Answer {
      try {
        const answer = solve(year, day, part, input);

        return {
          ok: true,

          answer,
        };
      } catch (error) {
        return {
          ok: false,

          error: error instanceof Error ? error : new Error("Unknown error"),
        };
      }
    }

    self.addEventListener("message", (event: MessageEvent<WorkerEvent>) => {
      const { data } = event;

      try {
        switch (data.type) {
          case "initialize": {
            const solutions = getAvailable();

            return sendMessage({
              type: "initialized",

              id: data.id,

              solutions,
            });
          }
          case "solve": {
            const { year, day, partOne, partTwo, input } = data;

            return sendMessage({
              type: "solved",

              id: data.id,

              partOne: partOne ? toAnswer(year, day, 1, input) : null,
              partTwo: partTwo ? toAnswer(year, day, 2, input) : null,
            });
          }
          default: {
            throw new Error(`Unknown event type`);
          }
        }
      } catch (error) {
        sendMessage({
          type: "error",

          id: data.id,

          reason: error instanceof Error ? error : new Error("Unknown error"),
        });
      }
    });
  })
  .catch(console.error);

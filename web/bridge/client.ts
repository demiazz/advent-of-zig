import { Answers, Solutions } from "@types";

import WasmWorker from "./worker?worker";
import { MainEvent, WorkerEvent, ReadyEvent } from "./types";

const worker = new WasmWorker();

const ready = new Promise<void>((resolve) => {
  const handler = (event: MessageEvent<ReadyEvent | MainEvent>) => {
    if (event.data.type === "ready") {
      resolve();

      worker.removeEventListener("message", handler);
    }
  };

  worker.addEventListener("message", handler);
});

function sendMessage(message: WorkerEvent) {
  worker.postMessage(message);
}

const nextId = (() => {
  let id = 0;

  return () => {
    const result = id;

    id += 1;

    return result;
  };
})();

export async function initialize(): Promise<Solutions> {
  await ready;

  const id = nextId();

  return new Promise((resolve, reject) => {
    const handler = ({ data }: MessageEvent<MainEvent>) => {
      if (data.id !== id) {
        return;
      }

      switch (data.type) {
        case "initialized": {
          resolve(data.solutions);

          break;
        }
        case "error": {
          reject(data.reason);

          break;
        }
      }

      worker.removeEventListener("message", handler);
    };

    worker.addEventListener("message", handler);

    sendMessage({ id, type: "initialize" });
  });
}

export async function solve(
  year: number,
  day: number,
  partOne: boolean,
  partTwo: boolean,
  input: string
): Promise<Answers> {
  await ready;

  const id = nextId();

  return new Promise((resolve, reject) => {
    const handler = ({ data }: MessageEvent<MainEvent>) => {
      if (data.id !== id) {
        return;
      }

      switch (data.type) {
        case "solved": {
          resolve({
            partOne: data.partOne,
            partTwo: data.partTwo,
          });

          break;
        }
        case "error": {
          reject(data.reason);

          break;
        }
      }

      worker.removeEventListener("message", handler);
    };

    worker.addEventListener("message", handler);

    sendMessage({ id, type: "solve", year, day, partOne, partTwo, input });
  });
}

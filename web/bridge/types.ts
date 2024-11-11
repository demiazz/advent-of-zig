import { Answers, Solutions } from "@/types";

type Event<
  Type extends string,
  Payload = {},
  Event = { type: Type; id: number } & Payload,
> = {
  [Key in keyof Event]: Event[Key];
};

export type InitializeEvent = Event<"initialize">;

export type SolveEvent = Event<
  "solve",
  {
    year: number;
    day: number;

    partOne: boolean;
    partTwo: boolean;

    input: string;
  }
>;

export type WorkerEvent = InitializeEvent | SolveEvent;

export type ReadyEvent = {
  type: "ready";
};

type InitializedEvent = Event<
  "initialized",
  {
    solutions: Solutions;
  }
>;

type ErrorEvent = Event<
  "error",
  {
    reason: Error;
  }
>;

type SolvedEvent = Event<"solved", Answers>;

export type MainEvent = InitializedEvent | ErrorEvent | SolvedEvent;

export type Answer =
  | {
      ok: true;

      answer: string;
    }
  | {
      ok: false;

      error: Error;
    }
  | null;

export type Answers = {
  partOne: Answer;
  partTwo: Answer;
};

export type SolveFn = (
  year: number,
  day: number,
  partOne: boolean,
  partTwo: boolean,
  input: string
) => Promise<Answers>;

// region Solutions

type DaySolutions = [true, true] | [true, false] | [false, true];

type YearSolutions = Map<number, DaySolutions>;

export type Solutions = Map<number, YearSolutions>;

// endregion Solutions

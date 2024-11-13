import { useCallback, useEffect, useRef, useState } from "preact/hooks";

import { Answers, SolveFn } from "@/types";

import { SubmitFn } from "../../Form";

type Options = {
  onSolve: SolveFn;

  year: number;
  day: number;
};

type Result = {
  isBusy: boolean;

  answers: Answers;

  onSubmit: SubmitFn;
};

export function useSolve({ day, onSolve, year }: Options): Result {
  const ref = useRef<number>(0);

  const [answers, setAnswers] = useState<Answers>({
    partOne: null,
    partTwo: null,
  });

  const [isBusy, setIsBusy] = useState<boolean>(false);

  useEffect(() => {
    setIsBusy(false);
    setAnswers({ partOne: null, partTwo: null });

    ref.current += 1;
  }, [year, day]);

  const handleSubmit = useCallback<SubmitFn>(
    async (isPartOne, isPartTwo, input) => {
      ref.current += 1;

      const id = ref.current;

      setIsBusy(true);
      setAnswers({ partOne: null, partTwo: null });

      const answers = await onSolve(year, day, isPartOne, isPartTwo, input);

      if (ref.current == id) {
        setIsBusy(false);
        setAnswers(answers);
      }
    },
    [day, year, onSolve]
  );

  return { isBusy, answers, onSubmit: handleSubmit };
}

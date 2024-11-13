import { Answers } from "@/types";

import { Result } from "./Results.Result";

type Props = {
  answers: Answers;
};

export const Results = ({ answers }: Props) => {
  if (answers.partOne == null && answers.partTwo == null) {
    return null;
  }

  return (
    <>
      {answers.partOne != null && (
        <Result label="Part 1" answer={answers.partOne} />
      )}
      {answers.partTwo != null && (
        <Result label="Part 2" answer={answers.partTwo} />
      )}
    </>
  );
};

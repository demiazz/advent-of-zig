import { FC } from "react";

import { Answers } from "@/types";

import { Result } from "./Results.Result";

type Props = {
  answers: Answers;
};

export const Results: FC<Props> = ({ answers }) => {
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

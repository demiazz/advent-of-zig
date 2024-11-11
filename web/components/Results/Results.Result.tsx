import { FC } from "react";

import { Answer } from "@/types";

import * as styles from "./Results.css";

type Props = {
  label: string;

  answer: Exclude<Answer, null>;
};

export const Result: FC<Props> = ({ label, answer }) => {
  if (answer.ok)
    if (answer != null) {
      return (
        <div className={styles.ok}>
          Answer for <span className={styles.label}>{label}</span>:
          <span className={styles.answer}> {answer.answer}</span>
        </div>
      );
    }

  return (
    <div className={styles.fail}>
      Error for <span className={styles.label}>{label}</span>:
      <span className={styles.answer}> {answer.error.message}</span>
    </div>
  );
};

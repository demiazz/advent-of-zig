import { ChangeEventHandler, memo, useState } from "react";

import { clsx } from "clsx/lite";

import * as styles from "./Form.css";

export type SubmitFn = (
  isPartOne: boolean,
  isPartTwo: boolean,
  input: string
) => void;

type Props = {
  className?: string;

  isDisabled?: boolean;

  isPartOneAvailable: boolean;
  isPartTwoAvailable: boolean;

  onSubmit: SubmitFn;
};

export const Form = memo<Props>(
  ({
    className,
    isDisabled,
    isPartOneAvailable,
    isPartTwoAvailable,
    onSubmit,
  }) => {
    const [value, setValue] = useState("");

    const isButtonDisabled = isDisabled || value.trim().length === 0;

    const handleChange: ChangeEventHandler<HTMLTextAreaElement> = (event) => {
      setValue(event.target.value);
    };

    const handlePartOne = () => {
      onSubmit(true, false, value);
    };

    const handlePartTwo = () => {
      onSubmit(false, true, value);
    };

    const handlePartBoth = () => {
      onSubmit(true, true, value);
    };

    return (
      <div className={clsx(styles.root, className)}>
        <textarea
          className={styles.input}
          disabled={isDisabled}
          onChange={handleChange}
          placeholder="Paste your input and select which parts you want to solve"
          rows={15}
          value={value}
        />
        <div className={styles.actions}>
          {isPartOneAvailable && (
            <button
              className={styles.action}
              disabled={isButtonDisabled}
              onClick={handlePartOne}
            >
              [Part One]
            </button>
          )}
          {isPartTwoAvailable && (
            <button
              className={styles.action}
              disabled={isButtonDisabled}
              onClick={handlePartTwo}
            >
              [Part Two]
            </button>
          )}
          {isPartOneAvailable && isPartTwoAvailable && (
            <button
              className={styles.action}
              disabled={isButtonDisabled}
              onClick={handlePartBoth}
            >
              [Both Parts]
            </button>
          )}
        </div>
      </div>
    );
  }
);

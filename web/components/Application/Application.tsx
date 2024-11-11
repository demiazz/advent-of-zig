import { FC } from "react";

import { Solutions, SolveFn } from "@/types";

import { Form } from "../Form";
import { Selector } from "../Selector";

import { useSelection, useSolve } from "./hooks";

import * as styles from "./Application.css";
import { Results } from "../Results";

type Props = {
  solutions: Solutions;

  onSolve: SolveFn;
};

export const Application: FC<Props> = ({ solutions, onSolve }) => {
  const {
    year,
    day,
    isPartOneAvailable,
    isPartTwoAvailable,
    availableDays,
    availableYears,
    onSelectYear,
    onSelectDay,
  } = useSelection(solutions);

  const { isBusy, answers, onSubmit } = useSolve({ day, onSolve, year });

  return (
    <div className={styles.root}>
      <h1 className={styles.title}>Advent of Zig</h1>

      <h2 className={styles.subTitle}>
        <span className={styles.subTitleDelimiter}>[</span>
        {year}
        <span className={styles.subTitleDelimiter}>]</span>
        <span className={styles.subTitleDelimiter}>[</span>
        {day}
        <span className={styles.subTitleDelimiter}>]</span>
      </h2>

      <Selector
        className={styles.years}
        onSelect={onSelectYear}
        options={availableYears}
        value={year}
      />
      <Selector
        className={styles.days}
        onSelect={onSelectDay}
        options={availableDays}
        value={day}
      />

      <Form
        className={styles.form}
        isDisabled={isBusy}
        isPartOneAvailable={isPartOneAvailable}
        isPartTwoAvailable={isPartTwoAvailable}
        onSubmit={onSubmit}
      />

      <div className={styles.results}>
        <Results answers={answers} />
      </div>
    </div>
  );
};

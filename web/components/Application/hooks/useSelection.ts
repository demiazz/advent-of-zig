import { useCallback, useMemo, useState } from "react";

import { Solutions } from "../../../types";

type Selection = {
  year: number;
  day: number;

  isPartOneAvailable: boolean;
  isPartTwoAvailable: boolean;
};

type Result = Selection & {
  availableYears: number[];
  availableDays: number[];

  onSelectYear: (year: number) => void;
  onSelectDay: (day: number) => void;
};

function findDefaults(solutions: Solutions): Selection {
  if (solutions.size == 0) {
    throw new Error("Solutions are an empty");
  }

  const year = Math.max(...solutions.keys());

  const days = solutions.get(year);

  if (days == null) {
    throw new Error(`Have no days with solutions for ${year} year`);
  }

  const day = Math.max(...days.keys());

  const flags = days.get(day);

  if (flags == null) {
    throw new Error(`Have no solutions for ${day} day of ${year} year`);
  }

  const [isPartOneAvailable, isPartTwoAvailable] = flags;

  return { year, day, isPartOneAvailable, isPartTwoAvailable };
}

export function useSelection(solutions: Solutions): Result {
  const [{ year, day, isPartOneAvailable, isPartTwoAvailable }, setSelection] =
    useState(() => findDefaults(solutions));

  const handleSelectDay = useCallback(
    (nextDay: number) => {
      setSelection((current) => {
        const days = solutions.get(current.year);

        if (days == null) {
          return current;
        }

        const flags = days.get(nextDay);

        if (flags == null) {
          return current;
        }

        const [isPartOneAvailable, isPartTwoAvailable] = flags;

        return {
          year: current.year,

          day: nextDay,

          isPartOneAvailable,
          isPartTwoAvailable,
        };
      });
    },
    [solutions],
  );

  const handleSelectYear = useCallback(
    (nextYear: number) => {
      setSelection((current) => {
        const days = solutions.get(nextYear);

        if (days == null) {
          return current;
        }

        const day = Math.max(...days.keys());

        const flags = days.get(day);

        if (flags == null) {
          return current;
        }

        const [isPartOneAvailable, isPartTwoAvailable] = flags;

        return { year: nextYear, day, isPartOneAvailable, isPartTwoAvailable };
      });
    },
    [solutions],
  );

  const availableYears = useMemo(() => [...solutions.keys()], [solutions]);

  const availableDays = useMemo(() => {
    const days = solutions.get(year);

    if (days == null) {
      return [];
    }

    return [...days.keys()];
  }, [solutions, year]);

  return {
    year,
    day,

    isPartOneAvailable,
    isPartTwoAvailable,

    availableYears,
    availableDays,

    onSelectYear: handleSelectYear,
    onSelectDay: handleSelectDay,
  };
}

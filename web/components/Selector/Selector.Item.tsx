import { ChangeEventHandler, memo } from "react";

import * as styles from "./Selector.css";

type Props = {
  name: string;

  isChecked: boolean;
  isDisabled?: boolean;

  onSelect: (value: number) => void;

  value: number;
};

export const Item = memo<Props>(
  ({ isChecked, isDisabled, onSelect, value }) => {
    const handleChange: ChangeEventHandler<HTMLInputElement> = (event) => {
      onSelect(parseInt(event.target.value));
    };

    return (
      <label className={styles.item}>
        <input
          className={styles.input}
          checked={isChecked}
          disabled={isDisabled}
          onChange={handleChange}
          type="radio"
          value={value}
        />
        [{value}]
      </label>
    );
  },
);

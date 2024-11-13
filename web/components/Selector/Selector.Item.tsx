import * as styles from "./Selector.css";

type Props = {
  name: string;

  isChecked: boolean;
  isDisabled?: boolean;

  onSelect: (value: number) => void;

  value: number;
};

export const Item = ({ isChecked, isDisabled, onSelect, value }: Props) => {
  const handleChange = (event: InputEvent) => {
    if (!(event.target instanceof HTMLInputElement)) {
      return;
    }

    onSelect(parseInt(event.target.value));
  };

  return (
    <label className={styles.item}>
      <input
        className={styles.input}
        checked={isChecked}
        disabled={isDisabled}
        onInput={handleChange}
        type="radio"
        value={value}
      />
      [{value}]
    </label>
  );
};

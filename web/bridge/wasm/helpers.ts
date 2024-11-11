import { Solutions } from "@types";

type AvailableItem = {
  year: number;
  day: number;
  part: number;
};

function offset(ptr: number, len: number): number {
  return ptr + len * Uint32Array.BYTES_PER_ELEMENT;
}

// NOTE: Reinterpret memory layout of `ExternSlice(Item, false)` struct.
export function parseAvailableItems(
  memory: WebAssembly.Memory,
  ptr: number
): AvailableItem[] {
  const view = new DataView(memory.buffer);

  const dataPtr = view.getUint32(ptr, true);
  const len = view.getUint32(offset(ptr, 1), true);

  const data = new Uint16Array(memory.buffer, dataPtr, len * 3);

  const items: AvailableItem[] = [];

  for (let idx = 0; idx < data.length / 3; idx += 1) {
    const offset = idx * 3;

    const [year, day, part] = data.slice(offset, offset + 3);

    items.push({ year, day, part });
  }

  return items;
}

// NOTE: Allocates `ExternSlice(u8, true)`, and write JS string to it.
export function transferString(
  memory: WebAssembly.Memory,
  allocate: (len: number) => number,
  data: string
): number {
  const buffer = new TextEncoder().encode(data);

  const len = buffer.byteLength;
  const ptr = allocate(len);

  const view = new DataView(memory.buffer);

  const bytesPtr = view.getInt32(ptr, true);
  const bytesLen = view.getUint32(offset(ptr, 1), true);

  new Uint8Array(memory.buffer, bytesPtr, bytesLen).set(buffer);

  return ptr;
}

// NOTE: Reinterpret memory layout of `ExternSlice(u8, true)` struct.
export function parseString(memory: WebAssembly.Memory, ptr: number): string {
  const view = new DataView(memory.buffer);

  const bytesPtr = view.getUint32(ptr, true);
  const bytesLen = view.getUint32(offset(ptr, 1), true);

  const bytes = new Uint8Array(memory.buffer, bytesPtr, bytesLen);

  return new TextDecoder().decode(bytes);
}

export function parseSolutions(items: AvailableItem[]): Solutions {
  const solutions = new Map();

  for (const { year, day, part } of items) {
    let yearMap = solutions.get(year);

    if (yearMap == null) {
      yearMap = new Map();

      solutions.set(year, yearMap);
    }

    let dayMap = yearMap.get(day);

    if (dayMap == null) {
      dayMap = [false, false];

      yearMap.set(day, dayMap);
    }

    dayMap[part - 1] = true;
  }

  return solutions;
}

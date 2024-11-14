### 2015/06:

There are very raw implementation with too much iterations. But what if we
can build search tree for rectangles, and just go through the whole grid the
only once, and then apply changes per point from all rectanges at once?
Would it be faster? Or building the search tree will be much complicated than
performance gains here?

```zig
  fn part_one() u32 {
    var count: u32 = 0;

    for (0..grid_size) |x| {
      for (0..grid_size) |y| {
        const it = findRectsAt(x, y);

        var state = false;

        while (it.next()) |action| {
          switch (action) {
            .on => state = true,
            .off => state = false,
            .toggle => state = !state;
          }
        }

        if (state) {
          count += 1
        }
      }
    }

    return count;
  }
```

We can use R-Tree for that purposes.

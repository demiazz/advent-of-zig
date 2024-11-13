YEAR=2015
DAY=1
PART=1

.PHONY: build-native build-web build dev-native dev-web

build-native:
	zig build

build-web:
	pnpm vite build

build: build-native build-web

dev-native:
	zig build run -- --year $(YEAR) --day $(DAY) --part $(PART) input.txt

dev-web:
	pnpm vite dev

test-native:
	zig build test

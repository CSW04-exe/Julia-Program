# Julia-Program

## Purpose

This is my submission for CS424-01 (Fall 2025) at UAH. The course has us implement the same
small assignment in a series of different languages so we can compare how each one handles
the same problem — I also have a Go version of this same basketball-stats assignment for
another course deliverable. This repository holds the Julia implementation
(`WardCS424Julia.jl`), written and tested in VS Code with Julia 1.12.0.

## Problem and Approach

The assignment: read a text file of basketball player statistics, compute two shooting
efficiency metrics for each player — effective field goal percentage (eFG%) and true
shooting percentage (TS%) — and print two reports: one sorted alphabetically by last name
then first name, and one sorted by TS% in descending order. Rows that are missing data or
fail to parse have to be kept in the output (not silently dropped) and flagged as bad data
instead of crashing the program.

My approach in Julia:

- `parse_line` splits each line on whitespace and expects a first name, last name, and
  eight numeric fields. If a line has fewer than 10 fields, or any of the numeric fields
  fail to parse as an integer, the row is still kept but marked with a `true` "bad row"
  flag in the last column instead of being thrown out.
- `read_players` reads the whole file line by line, builds one row array per line, and
  stacks them into a single matrix with `reduce(vcat, permutedims.(rows))`.
- `efg` and `ts` compute the two percentages from named column indices, short-circuiting
  to `0.0` for a bad row or a zero-attempt denominator so nothing divides by zero.
- `main` prompts for a filename, reads and sorts the matrix by last/first name, then calls
  `print_reports`, which prints the name-sorted report, then re-sorts a copy by TS%
  (descending, with bad rows pushed to the bottom via `-Inf`) and prints that too.

## Structure and Methodologies

- **Standard library only** — the program `using Printf` for `@sprintf`/`@printf`
  formatted output; no external packages are required.
- **Matrix-of-Any as the data structure** — each parsed player is a `Vector{Any}` mixing
  strings, integers, and a boolean flag; `read_players` stacks these into a 2D matrix with
  `permutedims` + `vcat`, and the rest of the program indexes into it a row (`eachrow`) or
  column at a time.
- **Named column constants** — `FIRST`, `LAST`, `POINTS`, `FG_MADE`, `FG_ATT`, `TP_MADE`,
  `FT_ATT`, and `BAD` are `const` integers used as column indices instead of magic numbers,
  which keeps `efg`, `ts`, and `print_row` readable.
- **Small pure functions composed together** — `parse_line`, `read_players`, `efg`, `ts`,
  `total_points`, `header_line`, `rule_line`, and `print_row` are each single-purpose and
  get composed inside `print_reports`.
- **Broadcasting and dot-syntax** — `tryparse.(Int, f[3:10])` and `Int.(nums)` apply the
  parse/conversion elementwise across the numeric fields in one line.
- **`sortperm` with a custom `by` key** — used twice: once to sort players by
  `(lowercase(last), lowercase(first))`, and once to sort by TS% descending while sending
  bad rows to the end with `-Inf`.
- **Do-block file handling** — `open(path, "r") do io ... end` and `eachline(io)` stream
  the input file line by line rather than reading it all into memory at once.
- **`@sprintf`/`@printf` field-width formatting** — right-aligned player names and
  fixed-width, one-decimal percentage columns (e.g. `%*s`, `%6.1f`) build the aligned
  report tables.
- **Script entry-point guard** — `if abspath(PROGRAM_FILE) == @__FILE__` so `main()` only
  runs when the file is executed directly, not if it's ever `include`d elsewhere.

## Process

1. The program starts and prompts the user at the terminal: `Enter input filename:`.
2. It reads the filename from `stdin` and opens that file.
3. Each non-blank line is stripped and passed to `parse_line`, which splits it into fields.
   A line with fewer than 10 fields, or with a numeric field that won't parse as an `Int`,
   becomes a row flagged `true` (bad); otherwise it becomes a full row of parsed stats
   flagged `false`.
4. All rows are stacked into one matrix representing the whole roster.
5. The matrix is sorted by last name, then first name (case-insensitively).
6. `print_reports` prints a header (`BASKETBALL TEAM REPORT --- N PLAYERS FOUND IN FILE`)
   and the total points scored by all valid players (`total_points`, which skips bad rows).
7. It prints the name-sorted table: for each player, either their eFG% and TS% (as
   percentages with one decimal place) or `*missing input data*` if the row was flagged bad.
8. It computes a second sort order — by TS% descending, bad rows last — and prints the same
   table again under an `ORDERED BY TS%` heading.
9. The program returns after both reports are printed; there is no output file, only
   console output.

### How to run

```
julia WardCS424Julia.jl
```

Then, at the `Enter input filename:` prompt, type the path to a whitespace-delimited stats
file where each non-blank line is: `FirstName LastName` followed by eight integer stat
fields (in order, the ones the program uses are points scored, field goals made, field
goals attempted, three-pointers made, and free throw attempts — the remaining numeric
fields are parsed but not used by the current formulas).

## Outcome

Running the program against a valid roster file produces two clearly labeled, aligned
console tables — one alphabetical, one ranked by TS% — plus a total-points line, all from a
single pass over the input data; feeding it a file with malformed or short lines proves the
error handling, since those players still show up (in the right sort position) with
`*missing input data*` instead of crashing the program or silently disappearing.

Building this was my first real Julia program, and it pushed me to pick up a language and
paradigm I hadn't used before in a short amount of time: 1-based indexing, broadcasting
with dot-syntax (`tryparse.`, `Int.`), multiple dispatch and type annotations like
`AbstractString`, do-block resource management, and `@printf`/`@sprintf`-style formatted
output that's closer to scientific/numerical computing than the general-purpose languages
I use more often. Comparing this Julia version side-by-side with my Go implementation of
the same assignment made the languages' differences concrete instead of abstract — things
like Julia's terse array/broadcast syntax versus Go's explicit loops, and Julia's dynamic,
matrix-oriented style versus Go's static typing. Overall, this assignment demonstrated to
me that I can get productive in an unfamiliar language quickly by leaning on its standard
library and idioms rather than trying to force patterns from a language I already know.

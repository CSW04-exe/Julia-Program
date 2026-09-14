# Julia Language Program — Basketball Stats Reporter

**Type:** Individual project
**Contributor:** Carter Ward
**Course:** CS 424-01 (Programming Languages), Fall 2025
**Completed:** 10/20/2025

## Purpose
This is my submission for CS424-01 at UAH, where the course has us implement the same
small assignment in a series of different languages to compare how each one handles it.
I also built a Go version of this basketball-stats assignment for another course
deliverable; this repository holds the Julia implementation (`WardCS424Julia.jl`), written
and tested in VS Code with Julia 1.12.0.

## Problem and Approach
The assignment: read a text file of basketball player statistics, compute effective field
goal percentage (eFG%) and true shooting percentage (TS%) for each player, and print two
reports — one sorted alphabetically by last then first name, one sorted by TS% descending.
Rows with missing or unparseable data must be kept (not dropped) and flagged as bad instead
of crashing the program. `parse_line` validates and flags each row, `read_players` streams
the file and stacks rows into a matrix, `efg`/`ts` compute the metrics (short-circuiting to
0.0 for bad rows or zero-attempt denominators), and `main` reads, sorts, and prints both
reports via `print_reports`.

## Structure and Methodologies
- Matrix-of-`Any` as the core data structure, built row-by-row with `permutedims` + `vcat`
- Named column constants (`FIRST`, `LAST`, `POINTS`, `FG_MADE`, `FG_ATT`, `TP_MADE`,
  `FT_ATT`, `BAD`) instead of magic indices
- Small pure functions composed together (`parse_line`, `read_players`, `efg`, `ts`,
  `total_points`, `print_row`, etc.)
- Broadcasting/dot-syntax (`tryparse.`, `Int.`) and `sortperm` with custom sort keys
- Do-block file I/O (`open(...) do io`) to stream input line by line
- `@sprintf`/`@printf` for aligned, fixed-width report formatting
- Standard library only (`Printf`); script entry-point guarded by
  `if abspath(PROGRAM_FILE) == @__FILE__`

## Process
1. Prompt for and read an input filename from stdin.
2. Parse each line into a stat row, flagging malformed rows as bad instead of dropping them.
3. Stack all rows into one matrix representing the roster.
4. Sort by last name, then first name, and print the name-sorted report with total points.
5. Re-sort a copy by TS% descending (bad rows last) and print that report too.

## Outcome
Running the program against a valid roster file produces two clearly labeled, aligned
console tables — one alphabetical, one ranked by TS% — plus a total-points line. Feeding it
malformed or short lines proves the error handling: those rows still appear in the right
sort position marked `*missing input data*` instead of crashing or vanishing. This was my
first real Julia program, and it pushed me to pick up 1-based indexing, broadcasting,
multiple dispatch, and `@printf`-style formatting in a short amount of time. Comparing it
side-by-side with my Go version made the languages' differences concrete — Julia's terse,
matrix-oriented dynamic style versus Go's explicit loops and static typing.

### How to run
```
julia WardCS424Julia.jl
```
At the `Enter input filename:` prompt, give a whitespace-delimited stats file where each
line is `FirstName LastName` followed by eight integer stat fields.

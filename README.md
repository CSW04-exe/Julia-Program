# Julia-Program

A Julia command-line program that reads basketball player statistics from a text file, computes each player's Effective Field Goal Percentage (eFG%) and True Shooting Percentage (TS%), flags rows with bad or missing data instead of crashing on them, and prints two clean, aligned reports: one sorted alphabetically by player name and one ranked by TS% from highest to lowest.

## 1. Purpose

This project was built for CS424-01 (Fall 2025) as an exercise in practical data processing with Julia: taking messy, real-world-shaped input (a plain text file of stat lines) and turning it into something a coach or analyst could actually read. Basketball advanced stats like eFG% and TS% are more informative than raw shooting percentages because they account for the extra value of three-pointers and the added weight of free throws, so the program exists to automate that math across an entire team roster instead of doing it by hand for every player.

Beyond the basketball framing, the assignment's real purpose was to practice core Julia skills that show up in any data-oriented program: reading and parsing unstructured text, building rows into a working data structure, applying formulas across that structure, handling bad input gracefully, sorting by different keys, and producing formatted console output.

## 2. Problem and approach

The problem was assigned by the course, but the specific shape of the solution was left to me. The requirements were:

- Read a file where each line represents one player's raw box-score numbers (points, field goals made/attempted, three-pointers made, free throws attempted, etc.).
- Compute eFG% = (FGM + 0.5 × 3PM) / FGA and TS% = PTS / (2 × (FGA + 0.44 × FTA)) for each player.
- Handle rows that are incomplete or contain non-numeric data without letting the program crash, and flag those players clearly instead of silently dropping them or reporting garbage numbers.
- Print one report sorted by last name, then first name, and a second report sorted by TS% descending.

My approach was to break the problem into small, single-purpose functions rather than one long script: a `parse_line` function that turns one line of text into a row (and marks it "bad" if it doesn't have enough valid numeric fields), a `read_players` function that turns a whole file into a matrix of rows, separate `efg` and `ts` functions that compute the two percentages (and safely return `0.0` instead of dividing by zero when a player has no attempts), and formatting/printing functions that are reused for both reports so the two outputs stay visually consistent. Guarding against division by zero and against non-numeric input with `tryparse` were the two biggest correctness concerns, since a stats file assembled by hand is exactly the kind of input likely to have a typo or a missing column.

## 3. Structure and methodologies

- **Language/runtime:** Julia 1.12.0, developed and run in VS Code, using only the Julia standard library — no `Project.toml`/`Manifest.toml` or third-party packages were needed. The only import is `Printf`, used for `@printf`/`@sprintf` formatted output.
- **Data structure:** Player records are represented as an `Any` vector-of-values per row (name fields as strings, stats as `Int`, plus a `Bool` flag for bad data), which are stacked with `permutedims`/`vcat`/`reduce` into a single matrix where each row is one player and each column is a fixed stat field. Named constants (`FIRST`, `LAST`, `POINTS`, `FG_MADE`, `FG_ATT`, `TP_MADE`, `FT_ATT`, `BAD`) are used as column indices instead of magic numbers, which makes the row-access code in `efg`, `ts`, and `print_row` self-documenting.
- **Parsing:** `split`/`strip` tokenize each line, and `tryparse.(Int, ...)` broadcasts a safe parse across the numeric fields; if any field fails to parse or too few fields are present, the whole row is marked bad rather than partially trusted.
- **Sorting:** Julia's `sortperm` is used twice — once with a tuple key `(lowercase(last), lowercase(first))` for the name-ordered report, and once with a key of `ts(r)` (with bad rows pinned to `-Inf` so they sort last) for the TS%-ordered report — rather than writing a custom sort routine.
- **Formatting:** `@printf`/`@sprintf` with fixed field widths (`NAMEW`, `NUMW`) produce aligned columns and a matching divider (`rule_line`) so both reports look like a real tabular report rather than raw `println` output.
- **I/O:** The program is interactive at the command line — it prompts with `Enter input filename:`, reads that path with `readline`, and processes the file with `open`/`eachline`, guarded by the `if abspath(PROGRAM_FILE) == @__FILE__` idiom so `main()` only runs when the file is executed directly (not when it's `include`d).

## 4. Process

The header comment block in `WardCS424Julia.jl` documents the program as a single-session build dated 10/20/2025, and the resulting code reads like it was designed top-down before being filled in: the column-index constants and formatting-width constants are declared first, establishing the "schema" the rest of the program relies on, followed by the parsing layer, then the calculation layer, then the presentation layer, and finally the orchestrating `main()` function at the bottom. That ordering suggests the actual process was to nail down what a row of data looks like first, then write pure functions that operate on a row (`parse_line`, `efg`, `ts`), and only afterward tackle the harder cross-cutting concerns — assembling many rows into a matrix, sorting them two different ways, and lining up columns of text so they print evenly.

Realistically, a good amount of the iteration likely happened around two areas that are easy to get wrong on the first pass and are visibly hardened in the final code: division-by-zero guards in `efg` and `ts` (both check their denominator before dividing), and the bad-data path, which had to be threaded through parsing (`parse_line` returning a flagged row instead of throwing), the math functions (returning `0.0` for bad rows instead of computing nonsense), the printing function (special-casing `*missing input data*` output), and the TS%-sort (forcing bad rows to the bottom with `-Inf`) — four separate places that all had to agree on what "bad" means for the report to come out correct and consistent. Formatting also reads as something tuned by trial and error: the comment noting that player names were right-aligned "for readability" and the `rule_line()` width being computed directly from the same constants used in `header_line()` both suggest the console output was run and visually checked repeatedly until the columns lined up correctly.

## 5. Outcome

The finished program successfully takes an arbitrary, human-typed stats file and produces two correctly computed, aligned, sorted reports without crashing on bad rows — the core functional requirement of the assignment. It correctly implements two real basketball advanced-stat formulas (eFG% and TS%) from their mathematical definitions, handles the standard failure modes of hand-entered data (too few fields, non-numeric fields, zero attempts), and demonstrates two distinct sorting strategies over the same dataset using Julia's `sortperm`.

Working through this assignment reinforced several concrete Julia and general programming skills:

- Writing small, single-responsibility functions (`parse_line`, `read_players`, `efg`, `ts`, `print_row`, `print_reports`) instead of one monolithic script, which made the bad-data handling and the dual-report logic much easier to reason about and keep correct.
- Defensive parsing with `tryparse` and explicit length checks, and thinking through every place a "bad" flag needs to be respected (math, sorting, printing) once it's introduced.
- Using named constants for column indices and layout widths instead of hard-coded numbers, which is a habit that scales well as a data schema or report format grows.
- Practical formatted I/O in Julia (`@printf`/`@sprintf`, field widths, building a matching divider line) to produce readable tabular console output.
- Comfort with Julia idioms for tabular data (row-wise iteration with `eachrow`, `sortperm` with custom key functions, broadcasting with `tryparse.`) as an alternative to reaching for an external DataFrame library for a task this size.

Overall, the project demonstrates the ability to take a semi-structured, error-prone real-world input and turn it into reliable, well-formatted output — a small but complete example of defensive data processing, which is a skill that generalizes well beyond basketball stats to any program that has to trust user-supplied files.

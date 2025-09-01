# Repository-Specific Copilot Instructions for adm-webr

These instructions are requirements for all Copilot-assisted editing in this repository. Please follow them strictly for all Quarto `.qmd` lesson files and related content.

## Quarto Exercise Block Structure

- For every exercise, the order **must** be:
  1. The didactic and instructional material in a normal Quarto paragraph for the reader.
  2. The first block for each exercise, i.e., the "defining block", must be the code block with a `caption` and `exercise` label (e.g.,
     ```{webr}
     #| caption: Exercise 4
     #| exercise: e4
     ```
     ). This block defines the start of the exercise.
  3. Optional hint div (always in a fenced div: `::: {.hint exercise="eX"}`)
  4. Solution block (always in a fenced div: `::: {.solution exercise="eX"}`)
  5. Check block (always last, never containing hints or instructions)

Each of the preceding should be contiguous and in that order, with no unrelated content except for one blank line between each component.

**Solution and Hint Requirements:**
- Every exercise must have a solution block (fenced div with `.solution`), and the solution must contain a code block in the required format.
- A hint block (fenced div with `.hint`) is optional. If a hint is present, it must be immediately followed by a solution block for the same exercise, and both must use the correct fenced div structure.
- No exercise should have a hint block without a corresponding solution block, but exercises may have a solution block without a hint.

If and only if the code that the student is instructed or expected to type in based on the didactic or instructional material for the exercise is exactly what R would output, add `#| output: false` to the defining block.

Each `.hint` or `.solution` fenced div must immediately enclose a `::: {.callout-note collapse="false"}` fenced div.
Both the `.callout-note` and the parent `.hint`/`.solution` divs must be closed with two `:::` lines, in this order:

  ```
  ::: {.hint exercise="eX"}
  ::: {.callout-note collapse="false"}
  [hint text]
  :::
  :::
  ```
  and similarly for `.solution`.

and similarly for `.solution`.

Never place a closing `:::` inside a code block. All divs must wrap around, not inside, code blocks.

There must be a blank line **before** every opening `:::` and **after** every closing `:::` for `.hint` and `.solution` divs.

Instructional text that serves as hints must be in hint divs, never in check blocks or code blocks.

Check blocks must only contain grading code (e.g., `gradethis::grade_this_code()`), never hints or instructions.

Do not alter instructional text preceding the defining blocks or after the check blocks when refactoring for compliance.

## General Formatting

- Use straight quotes (`"`) in all fenced div attributes, never curly quotes.
- Do not duplicate or lose any content when refactoring from swirl YAML code.
- If you find a stray or empty `:::` not closing a real div, remove it.
- Always preserve the logical and pedagogical flow of the lesson.

## Process

- When in doubt, ask for confirmation after the first few changes before sweeping the whole file.
- If the user requests a repo-wide sweep, apply the above rules to all `.qmd` files in the repository.
- Document any additional repo-specific conventions here as they arise.

---
_Last updated: 2025-08-30_

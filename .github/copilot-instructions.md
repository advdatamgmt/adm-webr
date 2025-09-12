# Robot-Mode Copilot Enforcement

## Atomic Rule Structure

1. All rules must be atomic, numbered, and unambiguous.
2. For every edit, Copilot MUST:
  - Extract a checklist of requirements from instructions and user prompt.
  - Validate output against this checklist before responding.
  - If any requirement is not met, halt and report the exact rule violated.
3. For Quarto exercises:
  - Didactic text must precede every exercise block and explicitly state the R code the user should type unless the exercise suggests the user is supposed to come up with it on their own.
  - The defining block must have both `caption` and `exercise` labels.
  - If shared objects are required, add the correct `envir` key.
  - Solution block must be present and contain a code block.
  - Hint block is optional but must be immediately followed by a solution block if present.
  - Check block must only contain grading code.
  - All fenced divs must use straight quotes and correct closing order.
  - All blocks must be sequentially numbered.
4. After every change, Copilot must run a validation sweep:
  - Confirm all requirements are satisfied.
  - If not, halt and report the first unmet requirement.
5. No natural language explanations unless explicitly requested.
6. If Copilot cannot comply, output: “ERROR: Unable to comply with rule [number]: [rule text]”.

# Environment Key for Shared Objects

- If an exercise requires R code execution that shares a common object (e.g., `l`), add an `envir` key to the defining block (e.g., `#| envir: env1`).
- Use `envY` where Y is a number representing the shared group of exercises that rely on a given object.
- Only include the `envir` key when needed for shared state between exercises.

# File Initialization

- Every new lesson `.qmd` file must begin with YAML front matter containing only the `title` field.
- Immediately after the YAML, include an blank line and the shared include line: `{{< include _static/_shared.qmd >}}`
- Narrative and didactic text should precede the first exercise, with all R code, function names, variable names, and literals formatted as `code`{.r}.
- Start with a `## Exposition` section with subsections as appropriate.
- If the overall flow becomes more experimental and less direct, change to a `## Experiment` section.
- Finally just before submission, start a `## Evaluate` section.

# Repository-Specific Copilot Instructions for adm-webr (Robot Mode)

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

## Submission Block Requirement

- The exercise count in `.progress_submit("lesson-name", N)` must always match the actual number of exercises in the lesson. Update this value whenever exercises are added or removed.


When adding new exercises, always append them after the last existing content or exercise in the file, unless a specific insertion point is requested.

The didactic/instructional text before each exercise must explicitly state any R code or assignment the user is expected to type, especially for object creation or reassignment. Do not rely on hints or solutions for essential instructions as they are not visible to the user.

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

- When clearing a file, always use a patch to remove all lines (not just an empty string edit) to ensure the file is truly empty.
  This guarantees no residual content remains.
  Do not use the insert_edit_into_file tool with an empty string for this purpose.
  Use apply_patch to remove all lines instead.
  
When in doubt, ask for confirmation after the first few changes before sweeping the whole file.
If the user requests a repo-wide sweep, apply the above rules to all `.qmd` files in the repository.
Document any additional repo-specific conventions here as they arise.

---
_Last updated: 2025-08-30_

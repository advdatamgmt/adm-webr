library(rcanvas)
library(rvest)
library(cli)
library(tidyverse)

df_template <- tibble(
    `...1` = numeric(),
    label = character(),
    user_code = character(),
    solution_code = character(),
    result = logical()
)

get_input <- function(prompt) {
    cli_text(prompt)
    if (interactive()) {
        as.integer(readline())
    } else {
        as.integer(readLines("stdin", n = 1))
    }
}

get_csv <- function(url) {
    if (url == "") {
        df_template
    } else {
        tryCatch(
            read_csv(url, show_col_types = FALSE, name_repair = "unique_quiet"),
            error = function(e) {
                cli_alert_danger("Failed to read CSV from {url}")
                df_template
            }
        )
    }
}

grade_it <- function(d) {
    tryCatch(
        {
            d %>%
                filter(result) %>%
                group_by(label) %>%
                slice_tail(n = 1) %>%
                ungroup() %>%
                pull(result) %>%
                sum()
        },
        error = function(e) {
            0L
        }
    )
}

course_id <- as.integer(readLines("_static/data/course_id.txt"))

assignments <- dget("_static/data/assignment_ids.txt")

set_canvas_domain("https://canvas.emory.edu")

cli_ol(names(assignments))

n <- get_input("Which assignment?")

cli_text("You selected: {assignments[[n]]}")

get_n_exercises <- function() {
    files <- names(assignments)
    # fix 09c
    files[
        files == "09-Reproducible-Research"
    ] <- "09c-Reproducible-Research-Exercise"
    files <- paste0("exercises/", files, ".qmd")

    extract_n <- function(f) {
        readLines(f) %>%
            grep(".progress_submit", ., value = TRUE) %>%
            sub(".*?, ?(\\d+)).*", "\\1", .) %>%
            as.integer()
    }

    purrr::map_int(files, extract_n)
}

assignments <- data.frame(
    name = names(assignments),
    id = unlist(assignments),
    n_exercises = get_n_exercises()
)

type_id <- assignments[[n, "id"]]

# get each students most recent assignment
submissions <- get_submissions(
    course_id = course_id,
    type = "assignments",
    type_id = type_id
) %>%
    group_by(user_id) %>%
    slice_max(submitted_at)

single_submissions <- purrr::map(
    submissions$user_id,
    ~ get_submission_single(
        course_id = course_id,
        type = "assignments",
        type_id = type_id,
        user_id = .x
    )
)

dfs <- map(single_submissions, "attachments") %>%
    map_chr(
        ~ {
            out <- .[1, "url"]
            if (length(out) == 0) "" else out
        }
    ) %>%
    map(get_csv)

grades <- dfs %>%
    map_int(grade_it) %>%
    `/`(assignments[[n, "n_exercises"]]) %>%
    `*`(10) %>%
    round(0)

submissions$grade <- grades

submissions %>%
    select(assignment_id, user_id, grade) %>%
    pwalk(
        ~ {
            if (..3 < 10) {
                name <- get_user_items(..2, "profile")$name
                grade <- ..3
                cli_alert_warning("{name} has a low grade of {grade}.")
            }
            grade_submission(
                course_id = course_id,
                assignment_id = ..1,
                user_id = ..2,
                grade = ..3
            )
        }
    )

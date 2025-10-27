fix_author <- function(x) {
    sub(
        "author:[[:blank:]]*(.+)$",
        "author: <div class=\"quarto-title-meta\"><div><div class=\"quarto-title-meta-heading\">Author</div><div class=\"quarto-title-meta-contents\"><p>\\1</p></div></div></div>",
        x,
        perl = TRUE
    )
}

check_it <- function(msg = "", test, add_to = list(msg = "", test = TRUE)) {
    msg = glue::glue("{add_to$msg}<br>{msg}: ", if (test) "✅" else "❌")
    list(msg = msg, test = test && add_to$test)
}

mock_quarto <- function(x, html = TRUE) {
    lines <- strsplit(x, "\n")[[1]]
    lines <- sapply(lines, fix_author)
    x <- paste(lines, collapse = "\n")

    out <- list(msg = "", test = TRUE)

    yaml_edge <- grep("---", lines)
    if (length(yaml_edge) < 2) {
        stop("Can't find YAML header starting & ending with '---'")
        found_yaml <- FALSE
    } else {
        found_yaml <- TRUE
    }
    yaml_lines <- paste(
        lines[(yaml_edge[1] + 1):(yaml_edge[2] - 1)],
        sep = "\n"
    )

    out <- check_it("Found YAML header", found_yaml, out)

    meta <- yaml::yaml.load(yaml_lines)

    out <- check_it(
        "-- HTML format detected",
        "html" %in% names(meta$format) || meta$format == "html",
        out
    )

    run_it <- out$test # later don't run if not HTML format

    if ("html" %in% names(meta$format)) {
        out <- check_it(
            "-- Embedding resources requested",
            "embed-resources" %in%
                names(meta$format$html) &&
                meta$format$html$`embed-resources`,
            out
        )
    } else {
        out <- check_it("-- Embedding resources requested", FALSE, out)
    }

    out <- check_it("-- Title detected", "title" %in% names(meta), out)
    out <- check_it("-- Author detected", "author" %in% names(meta), out)

    if (run_it) {
        rendered <- litedown::mark(
            litedown::fuse(
                x,
                ".md"
            ),
            meta = list(
                `header-includes` = '<style type="text/css">
                    .frontmatter { text-align: left; }
                    .author { 
                        text-transform: uppercase;
                        margin-top: 1em;
                        font-size: .9em;
                        opacity: .8;
                        font-weight: 400; 
                    }
                    .quarto-title-meta p {
                        margin: 0;
                        padding: 0;
                    }
                    .frontmatter .author h2 {
                        font-size: unset;
                        font-weight: unset;
                    }
                </style>'
            )
        )
        html_tables <- rvest::read_html(rendered) |>
            rvest::html_elements("table")

        test_df <- data.frame(
            a = c(4, 6, 8),
            b = c("26.7", "19.7", "15.1"),
            c = c("(4.51)", "(1.45)", "(2.56)"),
            d = c("2.3", "3.1", "4.0"),
            e = c("(0.57)", "(0.36)", "(0.76)")
        )

        dfs <- lapply(html_tables, rvest::html_table, convert = FALSE)

        tbl_out <- list(msg = "<br>", test = TRUE)

        for (df in seq_along(dfs)) {
            tbl_out$test <- TRUE
            tbl_out <- check_it(
                glue::glue("---- Table {df} of {length(dfs)} has 5 columns"),
                NCOL(dfs[[df]]) == 5,
                tbl_out
            )
            if (!tbl_out$test) {
                next
            }
            for (col in seq_along(dfs[[df]])) {
                tbl_out <- check_it(
                    glue::glue(
                        "------ Column {col} matches expected"
                    ),
                    identical(
                        as.character(as.data.frame(dfs[[df]])[, col]),
                        as.character(test_df[, col])
                    ),
                    tbl_out
                )
                if (!tbl_out$test) break
            }
            if (tbl_out$test) break
        }
    } else {
        tbl_out <- list(msg = "<br>", test = FALSE)
        out <- check_it(
            "-- Table not checked because not HTML format",
            FALSE,
            out
        )
        rendered <- "<p>Not rendered (not HTML format)</p>"
    }

    if (html) {
        htmltools::HTML(glue::glue(
            '<iframe style="width:100%; margin-bottom: 1em; padding: 1em; min-height: 350px; border: 2px solid black;"src="data:text/html;charset=utf-8;base64,{base64enc::base64encode(charToRaw(rendered))}"></iframe>'
        ))
    } else {
        out$msg <- paste0(out$msg, tbl_out$msg)
        out$test <- out$test && tbl_out$test
        return(out)
    }
}

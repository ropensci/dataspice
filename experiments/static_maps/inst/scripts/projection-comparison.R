#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(script_arg)) {
  stop("Run this entrypoint with Rscript.", call. = FALSE)
}

script_path <- normalizePath(sub("^--file=", "", script_arg[1]))
project_root <- normalizePath(file.path(dirname(script_path), "../.."))
default_output <- if (file.exists(file.path(project_root, "DESCRIPTION"))) {
  file.path(project_root, "reports", "projection-method-comparison.html")
} else {
  file.path(getwd(), "reports", "projection-method-comparison.html")
}
output_file <- if (length(args)) args[1] else default_output

staticmaps::generate_projection_comparison(output_file = output_file)

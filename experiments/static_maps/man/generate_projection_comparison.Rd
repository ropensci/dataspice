\name{generate_projection_comparison}
\alias{generate_projection_comparison}
\title{Generate the Static Map Projection Comparison Report}
\usage{
generate_projection_comparison(
  output_file = file.path("reports", "projection-method-comparison.html"),
  bbox_file = system.file("extdata", "test-bboxes.csv", package = "staticmaps")
)
}
\arguments{
\item{output_file}{Path for the generated self-contained HTML report. Its parent
folder is created if necessary.}
\item{bbox_file}{CSV file containing the test bounding boxes. Defaults to the
package's bundled dataset.}
}
\value{
The normalized path to the generated report, returned invisibly.
}
\description{
Renders the four projection strategies for each test extent and writes an
offline-capable HTML report with embedded PNG images, synchronized method
selection, and linked detailed figures. Requires the optional packages
\pkg{crsuggest}, \pkg{projWiz}, \pkg{htmltools}, and \pkg{maps}.
}

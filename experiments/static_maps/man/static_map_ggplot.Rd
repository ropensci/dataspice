\name{static_map_ggplot}
\alias{static_map_ggplot}
\title{Render a Static Map with ggplot2}
\usage{
static_map_ggplot(box)
}
\arguments{
\item{box}{A Schema.org GeoShape box string in north, east, south, west order.}
}
\value{
A base64-encoded PNG data URI.
}
\description{
Draws a world map and highlights the supplied bounding box using ggplot2.
}

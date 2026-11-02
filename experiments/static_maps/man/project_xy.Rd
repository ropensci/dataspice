\name{project_xy}
\alias{project_xy}
\title{Project Longitude/Latitude Coordinates}
\usage{
project_xy(lon, lat, crs)
}
\arguments{
\item{lon}{Numeric longitude coordinates in degrees.}
\item{lat}{Numeric latitude coordinates in degrees.}
\item{crs}{A coordinate reference system accepted by \code{sf::st_crs()}.}
}
\value{
A data frame with projected \code{x} and \code{y} coordinates. Missing or
non-finite input coordinate pairs are retained as \code{NA} values.
}
\description{
Transforms longitude/latitude coordinates from WGS 84 using \code{sf::st_transform()},
which delegates projection calculations to PROJ.
}

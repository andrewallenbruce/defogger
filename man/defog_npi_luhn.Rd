% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/defog_npi_luhn.R
\name{defog_npi_luhn}
\alias{defog_npi_luhn}
\title{Validate NPI input}
\usage{
defog_npi_luhn(npi)
}
\arguments{
\item{npi}{10-digit National Provider Identifier (NPI)}
}
\value{
boolean, TRUE or FALSE
}
\description{
Checks NPI for compliance with the Luhn algorithm
}
\examples{
defog_npi_luhn(1528060837)
}
\keyword{internal}

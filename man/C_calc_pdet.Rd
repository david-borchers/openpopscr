% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{C_calc_pdet}
\alias{C_calc_pdet}
\title{Computes detection probability (seen at least once) for Jolly-Seber model}
\usage{
C_calc_pdet(J, pr0, pr_captures, tpms, num_states)
}
\arguments{
\item{J}{total number of occasions}

\item{pr0}{initial distribution over life states}

\item{pr_captures}{list of empty capture histories, see calc_pdet() in JsModel}

\item{tpms}{output of calc_tpms() in JsModel}
}
\value{
pdet = probability seen at some time on the survey
}
\description{
Computes detection probability (seen at least once) for Jolly-Seber model
}

# Copyright (c) 2017 Richard Glennie
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################
# openpopscr project: open population spatial capture-recapture 
#
# file description: scr data class based on secr package objects 
#
################################################################################

#' Spatial capture-recapture data class 
#' 
#' @description Encapsulates data from spatial capture-recapture survey into a single 
#' object. Object can be created using $new with arguments: 
#' \itemize{
#'   \item capthist: capture history object from secr package with trap information included
#'   \item mesh: mask object from secr package
#'   \item time: optional vector of numeric time each occasion took place at 
#'     (used for irregularly space occasions). Default is vector of ones.
#' }
#' 
#' Methods include: 
#' \itemize{
#'  \item capthist(): return capture history object 
#'  \item traps(): return traps object 
#'  \item mesh(): return mesh object
#'  \item time(): return time vector 
#'  \item n(): return number of individuals seen over the entire survey
#'  \item n_occasions(): return number of capture occasions in the survey
#'  \item n_traps(): return number of traps used at some time in the survey
#'  \item n_meshpts(): return number of mesh points 
#'  \item area(): return total area of the mesh 
#'  \item distance(): return matrix with (i,j)th entry the distance from trap i to mesh point j
#' }
#' 
ScrData <- R6Class("ScrData", 
  public = list( 
    initialize = function(capthist, mesh, time = NULL) {
      private$capthist_ <- capthist 
      if (is.null(secr::usage(secr::traps(capthist)))) {
        secr::usage(secr::traps(private$capthist_)) <- matrix(1, nr = dim(capthist)[3], nc = dim(capthist)[2])
      }
      private$mesh_ <- mesh
      private$time_ <- time
    },
    
    print = function() {
       plot(self$mesh())
       plot(self$traps(), add = T)
       plot(self$capthist(), add = T)
       print(summary(self$capthist())[[4]])
    },
   
    capthist = function() {return(private$capthist_)},
    traps = function() {return(traps(private$capthist_))},
    mesh = function() {return(private$mesh_)},
    time = function() {return(private$time_)},
    
    n = function() {return(dim(private$capthist_)[1])},
    n_occasions = function() {return(dim(private$capthist_)[2])},
    n_traps = function() {return(dim(private$capthist_)[3])}, 
    n_meshpts = function() {return(dim(private$mesh_)[1])},
    area = function() {return(self$n_meshpts() * attributes(private$mesh_)$area * 0.01)},
    
    distances = function() {
      dist_to_row <- function(r) {
        dist <- function(r2) {
          sqrt(sum((r2 - r)^2))
        }
        apply(private$mesh_, 1, dist)
      }
      return(t(apply(self$traps(), 1, dist_to_row)))
    } 
    
  ), 
  
  private = list(
    capthist_ = NULL, 
    mesh_ = NULL,
    time_ = NULL, 
    covs_ = NULL 
  )
)








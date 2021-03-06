# Copyright (c) 2018 Richard Glennie
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

#' SCR with transience model class 
#' 
#' @description Spatial capture-recapture model with transience: fits model, formats inference, and 
#' simulates from fitted model. This model inherits all the functions of the 
#' JsModel class. Functions that are different or additional are documented here. 
#' \itemize{
#'   \item form: a named list of formulae for each parameter (~1 for constant)
#'   \item scr_data: a ScrData object 
#'   \item start: a named list of starting values 
#'   \item print (default = TRUE): if TRUE then helpful output is printed
#' }
#' 
#' Methods include: 
#' \itemize{
#'  \item calc_initial_distribution(): computes initial distribution over life states (unborn, alive, dead)
#'  \item calc_D_llk(): computes the likelihood of the D parameter
#'  \item calc_pdet(): compute probability of being detected at least once during the survey
#'  \item calc_llk(): compute log-likelihood at current parameter values 
#'  \item fit: fit the model by obtaining the maximum likelihood estimates. Estimates of
#'        density are obtained from parametric boostrap with nsim resamples. 
#'  \item simulate(): simulate ScrData object from fitted model
#' }
#' 
ScrTransientModel <- R6Class("ScrTransientModel",
                             inherit = ScrModel, 
  public = list(
    
    initialize = function(form, data, start, detectfn = NULL, print = TRUE) {
      if (print) cat("Creating rectangular mesh......")
      newmesh <- rectangularMask(data$mesh())
      private$dx_ <- attr(newmesh, "spacing")
      private$inside_ <- as.numeric(pointsInPolygon(newmesh, data$mesh()))
      cov_list <- data$get_cov_list() 
      private$data_ <- ScrData$new(data$capthist(), newmesh, data$time(), cov_list$cov, cov_list$cov_type)
      box <- attributes(newmesh)$boundingbox
      region <- c(diff(box[1:2, 1]), diff(box[c(1, 3), 2]))
      private$num_cells_ <- numeric(3)
      private$num_cells_[1] <- nrow(newmesh)
      private$num_cells_[2] <- floor(region[1] / private$dx_)
      private$num_cells_[3] <- nrow(newmesh) / private$num_cells_[2]
      if (print) cat("done\n")
      if (print) cat("Reading formulae.......")
      private$form_ <- form
      par_names <- sapply(form, function(f){f[[2]]})
      # detection function 
      if (is.null(detectfn)) {
        private$detfn_ <- DetFn$new()
      } else if (class(detectfn)[1] == "character") {
        private$detfn_ <- DetFn$new(fn = detectfn)
      } else {
        private$detfn_ <- detectfn 
      }
      for (i in 1:private$detfn_$npars()) {
        find <- par_names == private$detfn_$par(i)
        if (all(!find)) stop("Parameters in formulae incorrect.")
        private$form_[[i]]<- form[find][[1]]
      }
      private$form_[[private$detfn_$npars() + 1]] <- form[par_names == "sd"][[1]]
      private$form_ <- lapply(private$form_, function(f) {delete.response(terms(f))})
      names(private$form_) <- c(private$detfn_$pars(), "sd")
      private$make_par() 
      private$link2response_ <- c(private$detfn_$link2response(), list("exp"), list("exp"))
      names(private$link2response_) <- c(private$detfn_$pars(), "sd", "D")
      private$response2link_ <- c(private$detfn_$response2link(), list("log"), list("log"))
      names(private$response2link_) <- c(private$detfn_$pars(), "sd", "D")
      if (print) cat("done\n")
      if (print) cat("Initialising parameters.......")
      private$initialise_par(start)
      if (print) cat("done\n")
      private$print_ = print 
    },
    
    calc_initial_distribution = function() {
      n_mesh <- private$data_$n_meshpts()
      pr0 <- matrix(1, nrow = n_mesh, ncol = 1, byrow = TRUE)
      pr0 <- pr0 * private$inside_
      pr0 <- pr0 / sum(pr0)
      return(pr0)
    },
    
    calc_D_llk = function() {
      D <- do.call(private$link2response_$D, list(self$par()$D))
      A <- sum(private$inside_) * private$dx_^2 / 1000^2
      n <- private$data_$n()
      pdet <- self$calc_pdet()
      llk <- n * log(D * A * pdet) - D * A * pdet - lfactorial(n)
      names(llk) <- NULL 
      return(llk)
    },
    
    calc_pdet = function() {
      # compute probability of zero capture history 
      enc_rate <- self$calc_encrate() 
      trap_usage <- usage(private$data_$traps())
      pr_empty <- list()
      for (j in 1:private$data_$n_occasions()) {
        pr_empty[[j]] <- matrix(1, nr = private$data_$n_meshpts(), nc = 1)
        pr_empty[[j]][, 1] <- exp(-t(trap_usage[, j]) %*% enc_rate[j,,])
      }
      pr0 <- self$calc_initial_distribution()
      tpms <- list(matrix(0, nr = 2, nc = 2))
      dt <- diff(self$data()$time())
      sd <- self$get_par("sd", m = 1)
      pdet <- C_calc_move_pdet(private$data_$n_occasions(), 
                               pr0, 
                               pr_empty, 
                               tpms, 
                               private$num_cells_,
                               private$inside_, 
                               private$dx_,
                               dt, 
                               sd,
                               1); 
      return(pdet)
    },
    
    calc_llk = function(param = NULL, names = NULL) {
      if (!is.null(names)) names(param) <- names 
      if (!is.null(param)) self$set_par(private$convert_vec2par(param));
      # initial distribution 
      pr0 <- self$calc_initial_distribution()
      # compute probability of capture histories 
      # across all individuals, occasions and traps 
      pr_capture <- self$calc_pr_capture()
      # compute likelihood for each individual
      n <- private$data_$n()
      n_occasions <- private$data_$n_occasions()
      n_meshpts <- private$data_$n_meshpts() 
      tpms <- list(matrix(0, nr = 2, nc = 2))
      dt <- diff(self$data()$time())
      sd <- self$get_par("sd", m = 1)
      llk <- C_calc_move_llk(n, 
                             n_occasions,
                             pr0, 
                             pr_capture, 
                             tpms,
                             private$num_cells_, 
                             private$inside_, 
                             private$dx_, 
                             dt, 
                             sd, 
                             1, 
                             rep(0, private$data_$n()))
      # compute log-likelihood
      llk <- llk - n * log(self$calc_pdet())
      llk <- llk + self$calc_D_llk()
      #plot(self$par()$beta[-1])
      cat("llk:", llk, "\n")
      return(llk)
    },
    
  simulate = function(seed = NULL) {
    if (!is.null(seed)) set.seed(seed)
    num.meshpts <- private$data_$n_meshpts()
    mesh <- private$data_$mesh()
    D <- do.call(private$link2response_$D, list(self$par()$D)) / 100
    # simulate population
    if (private$print_) cat("Simulating population.......")
    pop <- sim.popn(D = D, core = mesh, Ndist = "poisson", buffertype = "convex")
    if (private$print_) cat("done\n")
    n_occasions <- private$data_$n_occasions()
    dt <- diff(private$data_$time())
    # generate capture histories
    lambda0 <- self$get_par("lambda0", m = 1)
    sigma <- self$get_par("sigma", j = 1, m = 1)
    if (private$print_) cat("Simulating capture histories.......")
    capture_history <- sim.capthist(private$data_$traps(), 
                                    popn = pop, 
                                    detectfn = "HHN", 
                                    detectpar = list(lambda0 = lambda0, 
                                                     sigma = sigma), 
                                    noccasions = n_occasions,
                                    renumber = FALSE)
    if (private$print_) cat("done\n")
    if (private$print_) cat("Creating ScrData object.......")
    new_dat <- ScrData$new(capture_history, mesh, private$data_$time())
    if (private$print_) cat("done\n")
    return(new_dat)
  }
  
),
                   
  private = list(
    dx_ = NULL, 
    inside_ = NULL,
    num_cells_ = NULL,
    
    make_par = function() {
      samp_cov <- private$data_$covs(j = 1, k = 1, m = 1)
      n_det_par <- private$detfn_$npars()
      private$par_ <- vector(mode = "list", length = n_det_par + 1)
      n_par <- numeric(n_det_par)
      for (par in 1:n_det_par) {
        X <- model.matrix(private$form_[[par]], data = samp_cov)
        n_par[par] <- ncol(X)
        par_vec <- rep(0, n_par[par])
        names(par_vec) <- colnames(X)
        private$par_[[par]] <- par_vec
      }
      private$par_[[n_det_par + 1]] <- 0
      private$par_[[n_det_par + 2]] <- 0
      names(private$par_) <- c(private$detfn_$pars(), "sd", "D") 
      return(invisible())
    }, 
    
    initialise_par = function(start) {
      n_det_par <- private$detfn_$npars()
      names <- private$detfn_$pars()
      for (i in 1:n_det_par) {
        private$par_[[i]][1] <- do.call(private$response2link_[[i]], 
                                        list(start[[i]]))
      }
      names(private$par_) <- c(names, "sd", "D")
      private$par_$sd[1] <-do.call(private$response2link_$sd, 
                                   list(start$sd))
      private$par_$D <- do.call(private$response2link_$D, 
                                list(start$D))
      return(invisible())
    }, 
    
    convert_vec2par = function(vec) {
      par <- NULL
      n_occasions <- private$data_$n_occasions()
      names <- names(vec)
      n_det_par <- self$detectfn()$npars()
      parnames <- self$detectfn()$pars()
      par <- vector(mode = "list", length = n_det_par)
      for (i in 1:n_det_par) {
        par[[i]] <- vec[grep(parnames[i], names)]
        names(par[[i]]) <- gsub(paste0(parnames[i],"."), "", names(par[[i]]))
      }
      names(par) <- parnames 
      par$sd <- vec[grep("sd", names)]
      names(par$sd) <- gsub("sd.", "", names(par$sd))
      par$D <- vec["D"]
      names(par$D) <- NULL 
      return(par)
    }
  )                 
)




## Jolly-Seber example 
library(openpopscr)
library(secr)

# simulate data -----------------------------------------------------------

# set truth 
true_par <- list(D = 1000, lambda0 = 1, sigma = 30, phi = 0.5, beta = 0.3)

# make detectors array 
detectors <- make.grid(nx = 7, ny = 7, spacing = 20, detector = "proximity")

# make mesh 
mesh <- make.mask(detectors, buffer = 100, nx = 64, ny = 64, type = "trapbuffer")

# set number of occasions to simulate
n_occasions <- 5

# simulate ScrData 
scrdat <- simulate_js_openscr(true_par, n_occasions, detectors, mesh)



# fit model ---------------------------------------------------------------

par <- list(lambda0 ~ 1, 
            sigma ~ 1, 
            beta ~ 1, 
            phi ~ 1)

start <- list(lambda0 = 2, 
              sigma = 20, 
              beta = 0.2, 
              phi = 0.5, 
              D = 1000)


oo <- JsModel$new(par, scrdat, start)

oo$calc_llk()

oo$fit()

oo

oo$get_par("lambda0", k = 1)
oo$get_par("sigma", k = 1)
oo$get_par("phi", k = 1)
oo$get_par("beta", k = 1)
oo$get_par("D")

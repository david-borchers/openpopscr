// Copyright (c) 2017 Richard Glennie, University of St Andrews
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files, to deal in the software
// without restriction, including without limitation the right to use, copy,
// modify, publish, distribute, sublicense, and/or sell copies of the software,
// and to permit persons to whom the software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//
////////////////////////////////////////////////////////////////////////////////
// openpopscr project: open population spatial capture-recapture modelling
//
// moveds.cpp: C++ functions to compute likelihood
//
////////////////////////////////////////////////////////////////////////////////
//
// [[Rcpp::depends(RcppArmadillo)]]
#include <iostream>
#include <RcppArmadillo.h>


//' Computes log-likelihood of Jolly-Seber model 
//'
//' @param n number of individuals 
//' @param J total number of occasions 
//' @param M total number of mesh points
//' @param pr0 initial distribution over life states
//' @param pr_capture output of calc_pr_capture() in JsModel
//' @param tpms output of calc_tpms() in JsModel
//' @param num_cores number of processor cores to use in parallelisation 
//'
//' @return log-likelihood value 
//' 
// [[Rcpp::export]]
double C_calc_llk(const int n, const int J, const int M, 
                  const arma::mat pr0, 
                  const Rcpp::List pr_capture, 
                  const Rcpp::List tpms,
                  const int num_cores) {
  
  arma::vec illk(n);
  double llk; 
  arma::mat pr;
  double sum_pr;
  arma::mat tpm; 
  for (int i = 0; i < n; ++i) {
    llk = 0; 
    pr = pr0; 
    Rcpp::NumericVector pr_capvec(Rcpp::as<Rcpp::NumericVector>(pr_capture[i])); 
    arma::cube pr_cap(pr_capvec.begin(), M, 3, J); 
    for (int j = 0; j < J - 1; ++j) {
      tpm = Rcpp::as<arma::mat>(tpms[j]); 
      pr %= pr_cap.slice(j); 
      pr *= tpm; 
      sum_pr = accu(pr); 
      llk += log(sum_pr); 
      pr /= sum_pr; 
    }
    pr %= pr_cap.slice(J - 1);
    llk += log(accu(pr)); 
    illk(i) = llk;  
  }
  return(accu(illk)); 
}

//' Computes detection probability (seen at least once) for Jolly-Seber model 
//'
//' @param J total number of occasions 
//' @param pr0 initial distribution over life states
//' @param pr_captures list of empty capture histories, see calc_pdet() in JsModel
//' @param tpms output of calc_tpms() in JsModel
//'
//' @return pdet = probability seen at some time on the survey 
//' 
// [[Rcpp::export]]
double C_calc_pdet(const int J, 
                arma::mat pr0, 
                Rcpp::List pr_captures,
                Rcpp::List tpms) {
  
  double pdet = 0; 
  arma::mat pr(pr0);
  double sum_pr;
  arma::mat tpm;
  arma::mat pr_capture; 
  for (int j = 0; j < J - 1; ++j) {
    pr_capture = Rcpp::as<arma::mat>(pr_captures[j]);
    tpm = Rcpp::as<arma::mat>(tpms[j]); 
    pr %= pr_capture; 
    pr *= tpm; 
    sum_pr = accu(pr); 
    pdet += log(sum_pr); 
    pr /= sum_pr; 
  }
  pr %= pr_capture;
  pdet += log(accu(pr)); 
  pdet = 1 - exp(pdet); 
  return(pdet); 
}


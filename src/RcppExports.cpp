// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// C_calc_D
arma::vec C_calc_D(const double D, const int J, arma::rowvec pr0, Rcpp::List tpms);
RcppExport SEXP openpopscr_C_calc_D(SEXP DSEXP, SEXP JSEXP, SEXP pr0SEXP, SEXP tpmsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const double >::type D(DSEXP);
    Rcpp::traits::input_parameter< const int >::type J(JSEXP);
    Rcpp::traits::input_parameter< arma::rowvec >::type pr0(pr0SEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type tpms(tpmsSEXP);
    rcpp_result_gen = Rcpp::wrap(C_calc_D(D, J, pr0, tpms));
    return rcpp_result_gen;
END_RCPP
}
// C_calc_llk
double C_calc_llk(const int n, const int J, const int M, const arma::mat pr0, const Rcpp::List pr_capture, const Rcpp::List tpms, const int num_cores);
RcppExport SEXP openpopscr_C_calc_llk(SEXP nSEXP, SEXP JSEXP, SEXP MSEXP, SEXP pr0SEXP, SEXP pr_captureSEXP, SEXP tpmsSEXP, SEXP num_coresSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const int >::type n(nSEXP);
    Rcpp::traits::input_parameter< const int >::type J(JSEXP);
    Rcpp::traits::input_parameter< const int >::type M(MSEXP);
    Rcpp::traits::input_parameter< const arma::mat >::type pr0(pr0SEXP);
    Rcpp::traits::input_parameter< const Rcpp::List >::type pr_capture(pr_captureSEXP);
    Rcpp::traits::input_parameter< const Rcpp::List >::type tpms(tpmsSEXP);
    Rcpp::traits::input_parameter< const int >::type num_cores(num_coresSEXP);
    rcpp_result_gen = Rcpp::wrap(C_calc_llk(n, J, M, pr0, pr_capture, tpms, num_cores));
    return rcpp_result_gen;
END_RCPP
}
// C_calc_pdet
double C_calc_pdet(const int J, arma::mat pr0, Rcpp::List pr_captures, Rcpp::List tpms);
RcppExport SEXP openpopscr_C_calc_pdet(SEXP JSEXP, SEXP pr0SEXP, SEXP pr_capturesSEXP, SEXP tpmsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const int >::type J(JSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type pr0(pr0SEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type pr_captures(pr_capturesSEXP);
    Rcpp::traits::input_parameter< Rcpp::List >::type tpms(tpmsSEXP);
    rcpp_result_gen = Rcpp::wrap(C_calc_pdet(J, pr0, pr_captures, tpms));
    return rcpp_result_gen;
END_RCPP
}
// C_calc_pr_capture
arma::field<arma::cube> C_calc_pr_capture(const int n, const int J, const int K, const int M, Rcpp::NumericVector& capvec, Rcpp::NumericVector& enc_rate, const arma::mat usage, const int num_cores);
RcppExport SEXP openpopscr_C_calc_pr_capture(SEXP nSEXP, SEXP JSEXP, SEXP KSEXP, SEXP MSEXP, SEXP capvecSEXP, SEXP enc_rateSEXP, SEXP usageSEXP, SEXP num_coresSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const int >::type n(nSEXP);
    Rcpp::traits::input_parameter< const int >::type J(JSEXP);
    Rcpp::traits::input_parameter< const int >::type K(KSEXP);
    Rcpp::traits::input_parameter< const int >::type M(MSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector& >::type capvec(capvecSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector& >::type enc_rate(enc_rateSEXP);
    Rcpp::traits::input_parameter< const arma::mat >::type usage(usageSEXP);
    Rcpp::traits::input_parameter< const int >::type num_cores(num_coresSEXP);
    rcpp_result_gen = Rcpp::wrap(C_calc_pr_capture(n, J, K, M, capvec, enc_rate, usage, num_cores));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"openpopscr_C_calc_D", (DL_FUNC) &openpopscr_C_calc_D, 4},
    {"openpopscr_C_calc_llk", (DL_FUNC) &openpopscr_C_calc_llk, 7},
    {"openpopscr_C_calc_pdet", (DL_FUNC) &openpopscr_C_calc_pdet, 4},
    {"openpopscr_C_calc_pr_capture", (DL_FUNC) &openpopscr_C_calc_pr_capture, 8},
    {NULL, NULL, 0}
};

RcppExport void R_init_openpopscr(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
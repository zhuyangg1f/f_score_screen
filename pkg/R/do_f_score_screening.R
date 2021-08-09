#' Perform F-Score Srenning
#'
#' Perform F-Score Srenning based on statistics
#'
#' @param symbol character object, ticker name
#' @param criteria_num  numeric object, states the number of f-score criteria needs to be met
#' @return a list object contains screening result based on annual/quarter report
#' @export
do_f_score_screening <- function(symbol,
                                 criteria_num = 8) {

  statistics <- get_f_score_statistics(symbol)

  # -------------------------------------------------------------------------------------------------------
  # Annual check

  # Y1 ROA positive
  annual_check1 <- statistics$annual_report[1, "annual_roa"] > 0
  # Y1 CFO positive
  annual_check2 <- statistics$annual_report[1, "annual_cfo"] > 0
  # Y1 ROA ratio > Y2 ROA ratio
  annual_check3 <- statistics$annual_report[1, "annual_roa"] > statistics$annual_report[2, "annual_roa"]
  # Y1 CFO > Y1 NET INCOME
  annual_check4 <- statistics$annual_report[1, "annual_cfo"] > statistics$annual_report[1, "annual_net_income"]
  # Y1 Long-term debt to asset ratio > Y2 Long-term debt to asset ratio
  annual_check5<- statistics$annual_report[1, "annual_long_term_debt_assets_ratio"] > statistics$annual_report[2, "annual_long_term_debt_assets_ratio"]
  # Y1 current ratio > Y2 current ratio
  annual_check6 <- statistics$annual_report[1, "annual_current_ratio"] > statistics$annual_report[2, "annual_current_ratio"]
  # Y1 avg shares outstanding <= Y2 avg shares outstanding
  annual_check7 <- statistics$annual_report[1, "annual_avg_shares_outstanding"] <= statistics$annual_report[2, "annual_avg_shares_outstanding"]
  # Y1 gross margin > Y2 gross margin
  annual_check8 <- statistics$annual_report[1, "annual_gross_margin"] > statistics$annual_report[2, "annual_gross_margin"]
  # Y1 assets turnover > Y2 assets turnover
  annual_check9 <- statistics$annual_report[1, "annual_asset_turnover"] > statistics$annual_report[2, "annual_asset_turnover"]

  # ------------------------------------------------------------------------------------------------
  # Quarter check

  # Y1 ROA positive
  quarter_check1 <- statistics$quarter_report[1, "quarter_roa"] > 0
  # Y1 CFO positive
  quarter_check2 <- statistics$quarter_report[1, "quarter_cfo"] > 0
  # Y1 ROA ratio > Y2 ROA ratio
  quarter_check3 <- statistics$quarter_report[1, "quarter_roa"] > statistics$quarter_report[5, "quarter_roa"]
  # Y1 CFO > Y1 NET INCOME
  quarter_check4 <- statistics$quarter_report[1, "quarter_cfo"] > statistics$quarter_report[1, "quarter_net_income"]
  # Y1 Long-term debt to asset ratio > Y2 Long-term debt to asset ratio
  quarter_check5<- statistics$quarter_report[1, "quarter_long_term_debt_assets_ratio"] > statistics$quarter_report[5, "quarter_long_term_debt_assets_ratio"]
  # Y1 current ratio > Y2 current ratio
  quarter_check6 <- statistics$quarter_report[1, "quarter_current_ratio"] > statistics$quarter_report[5, "quarter_current_ratio"]
  # Y1 avg shares outstanding <= Y2 avg shares outstanding
  quarter_check7 <- statistics$quarter_report[1, "quarter_avg_shares_outstanding"] <= statistics$quarter_report[5, "quarter_avg_shares_outstanding"]
  # Y1 gross margin > Y2 gross margin
  quarter_check8 <- statistics$quarter_report[1, "quarter_gross_margin"] > statistics$quarter_report[5, "quarter_gross_margin"]
  # Y1 assets turnover > Y2 assets turnover
  quarter_check9 <- statistics$quarter_report[1, "quarter_asset_turnover"] > statistics$quarter_report[5, "quarter_asset_turnover"]

  if(sum(annual_check1, annual_check2, annual_check3,
         annual_check4, annual_check5, annual_check6,
         annual_check7, annual_check8, annual_check9, na.rm = T) >= criteria_num) {
    annual_check <- TRUE
  } else {
    annual_check <- FALSE
  }

  if(sum(quarter_check1, quarter_check2, quarter_check3,
         quarter_check4, quarter_check5, quarter_check6,
         quarter_check7, quarter_check8, quarter_check9, na.rm = T) >= criteria_num) {
    quarter_check <- TRUE
  } else {
    quarter_check <- FALSE
  }

  output <- data.frame(
    symbol = symbol,
    capital = as.numeric(statistics$capital),
    annual_check = annual_check,
    quarter_check = quarter_check
  )

  return(output)

}

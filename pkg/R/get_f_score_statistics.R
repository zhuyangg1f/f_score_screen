#' Get F-Score Statistics
#'
#' Get F-Score Statistics based on calculation
#'
#' @param symbol character object, ticker name
#' @return a list object contains f-score statistics
#' @importFrom lubridate as_date
#' @export
get_f_score_statistics <- function(symbol) {

  # load finance statements
  overview <- get_raw_api_content(symbol, "OVERVIEW")
  income_statement <- get_raw_api_content(symbol, "INCOME_STATEMENT")
  balance_sheet <- get_raw_api_content(symbol, "BALANCE_SHEET")
  cash_flow <- get_raw_api_content(symbol, "CASH_FLOW")
  earnings <- get_raw_api_content(symbol, "EARNINGS")
  capital <- overview$MarketCapitalization

  # quit if less than 3 years
  if(dim(balance_sheet$annualReports)[1] < 3) {

    output <- list(
      symbol = symbol,
      capital = capital,
      annual_report = data.frame(),
      quarter_report = data.frame()
    )

    return(output)
  }

  # ------------------------------------------------------------------------------------

  # calculate annual key statistics
  annual_net_income <- as.numeric(income_statement$annualReports$netIncome)[1:3]
  annual_total_assets <- as.numeric(balance_sheet$annualReports$totalAssets)[1:3]
  annual_long_term_debt <- as.numeric(balance_sheet$annualReports$longTermDebt)[1:3]
  annual_current_assets <- as.numeric(balance_sheet$annualReports$totalCurrentAssets)[1:3]
  annual_current_liabilities <- as.numeric(balance_sheet$annualReports$totalLiabilities)[1:3]
  annual_revenue <- as.numeric(income_statement$annualReports$totalRevenue)[1:3]
  annual_cogs <- as.numeric(income_statement$annualReports$costofGoodsAndServicesSold)[1:3]
  # ROA = NET INCOME / TOTAL ASSETS
  try( annual_avg_total_assets <- (annual_total_assets +
    lead(annual_total_assets,
         default = annual_total_assets[length(annual_total_assets)]))/2 )
  if(length(annual_avg_total_assets) != length(annual_total_assets)) {
    annual_avg_total_assets <- annual_total_assets
  }

  annual_roa <- annual_net_income/annual_total_assets
  # CASH FROM OPERATIONS
  annual_cfo <- as.numeric(cash_flow$annualReports$operatingCashflow)[1:3]
  # ROA RATIO = NET INCOME / AVG TOTAL ASSETS
  annual_roa_ratio <- annual_net_income/annual_avg_total_assets
  # LONG TERM DEBT TO ASSETS RATIO
  annual_long_term_debt_assets_ratio <- annual_long_term_debt/annual_total_assets
  # CURRENT RATIO
  annual_current_ratio <- annual_current_assets/annual_current_liabilities
  # AVG SHARES OUTSTANDING
  annual_avg_shares_outstanding <- as.numeric(balance_sheet$annualReports$commonStockSharesOutstanding)[1:3]
  # GROSS MARGIN
  annual_gross_margin <- annual_revenue/(annual_revenue - annual_cogs)
  # ASSET TURNOVER
  annual_asset_turnover <- annual_revenue/annual_avg_total_assets

  annual_report <- data.frame(
    fiscal_date = as.character(balance_sheet$annualReports$fiscalDateEnding[1:3]),
    annual_net_income = annual_net_income,
    annual_roa = annual_roa,
    annual_cfo = annual_cfo,
    annual_roa_ratio = annual_roa_ratio,
    annual_long_term_debt_assets_ratio = annual_long_term_debt_assets_ratio,
    annual_current_ratio = annual_current_ratio,
    annual_avg_shares_outstanding = annual_avg_shares_outstanding,
    annual_gross_margin = annual_gross_margin,
    annual_asset_turnover = annual_asset_turnover
  )

  # ------------------------------------------------------------------------------------------

  # calculate annual key statistics
  quarter_net_income <- as.numeric(income_statement$quarterlyReports$netIncome)[1:13]
  quarter_total_assets <- as.numeric(balance_sheet$quarterlyReports$totalAssets)[1:13]
  quarter_long_term_debt <- as.numeric(balance_sheet$quarterlyReports$longTermDebt)[1:13]
  quarter_current_assets <- as.numeric(balance_sheet$quarterlyReports$totalCurrentAssets)[1:13]
  quarter_current_liabilities <- as.numeric(balance_sheet$quarterlyReports$totalLiabilities)[1:13]
  quarter_revenue <- as.numeric(income_statement$quarterlyReports$totalRevenue)[1:13]
  quarter_cogs <- as.numeric(income_statement$quarterlyReports$costofGoodsAndServicesSold)[1:13]
  # ROA = NET INCOME / TOTAL ASSETS
  try(quarter_avg_total_assets <- (quarter_total_assets +
    lead(quarter_total_assets,
         default = quarter_total_assets[length(quarter_total_assets)]))/2)
  if(length(quarter_avg_total_assets) != length(quarter_total_assets)) {
    quarter_avg_total_assets <- quarter_total_assets
  }

  quarter_roa <- quarter_net_income/quarter_total_assets
  # CASH FROM OPERATIONS
  quarter_cfo <- as.numeric(cash_flow$quarterlyReports$operatingCashflow)[1:13]
  # ROA RATIO = NET INCOME / AVG TOTAL ASSETS
  quarter_roa_ratio <- quarter_net_income/quarter_avg_total_assets
  # LONG TERM DEBT TO ASSETS RATIO
  quarter_long_term_debt_assets_ratio <- quarter_long_term_debt/quarter_total_assets
  # CURRENT RATIO
  quarter_current_ratio <- quarter_current_assets/quarter_current_liabilities
  # AVG SHARES OUTSTANDING
  quarter_avg_shares_outstanding <- as.numeric(balance_sheet$quarterlyReports$commonStockSharesOutstanding)[1:13]
  # GROSS MARGIN
  quarter_gross_margin <- quarter_revenue/(quarter_revenue - quarter_cogs)
  # ASSET TURNOVER
  quarter_asset_turnover <- quarter_revenue/quarter_avg_total_assets

  quarter_report <- data.frame(
    fiscal_date = as.character(balance_sheet$quarterlyReports$fiscalDateEnding[1:13]),
    quarter_net_income = quarter_net_income,
    quarter_roa = quarter_roa,
    quarter_cfo = quarter_cfo,
    quarter_roa_ratio = quarter_roa_ratio,
    quarter_long_term_debt_assets_ratio = quarter_long_term_debt_assets_ratio,
    quarter_current_ratio = quarter_current_ratio,
    quarter_avg_shares_outstanding = quarter_avg_shares_outstanding,
    quarter_gross_margin = quarter_gross_margin,
    quarter_asset_turnover = quarter_asset_turnover
  )

  output <- list(
    symbol = symbol,
    capital = capital,
    annual_report = annual_report,
    quarter_report = quarter_report
  )

  return(output)

}

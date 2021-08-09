#' Find Target Stock
#'
#' Find target stock by different strategy
#'
#' @param symbol_list vector of characters, a list of tickers
#' @param strategy character object, strategy to be used
#' @return a list of tickers satisfy the strategy
#' @export
find_target_stocks <- function(symbol_list,
                               strategy = "f-score") {

  screening_result <- data.frame()

  if(strategy == "f-score") {

    for (i in 1:length(symbol_list)) {

      result_tmp <- try(suppressWarnings(do_f_score_screening(symbol_list[i])), silent = T)

      if(class(result_tmp) == "try-error") {

        result_tmp <- data.frame(
          symbol = symbol_list[i],
          capital = NA,
          annual_check = FALSE,
          quarter_check = FALSE
        )

      }

      screening_result <- rbind.data.frame(screening_result, result_tmp)

      # restriction due to API limit
      Sys.sleep(5)

    }

  }

  return(screening_result)


}

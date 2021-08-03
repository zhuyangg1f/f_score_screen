#' Create API URL
#'
#' Create API URL to send request to alphavantage
#'
#' @param symbol character object, ticker name
#' @param api_fun character object, api function defined by alphavantage
#' @param api_key character object, api key from alphavantage
#' @param data_type character object, either json or csv
#' @return a url contains API request information
#' @importFrom stringr str_c
#' @importFrom glue glue
#' @export
create_api_url <- function(symbol,
                           api_fun,
                           api_key = "4HQVKYYYNZTDVUJ2",
                           data_type = "json",
                           ...) {

  if (missing(symbol)) symbol <- NULL

  # Checks API key
  if (is.null(api_key)) {
    stop("Set API key using av_api_key(). If you do not have an API key, please claim your free API key on (https://www.alphavantage.co/support/#api-key). It should take less than 20 seconds, and is free permanently.",
         call. = FALSE)
  }

  # Create API URL
  dots <- list()
  dots$symbol <- symbol
  dots$apikey <- api_key
  dots$datatype <- data_type

  url_params <- stringr::str_c(names(dots), dots, sep = "=", collapse = "&")
  url <- glue::glue("https://www.alphavantage.co/query?function={api_fun}&{url_params}")

  return(url)

}

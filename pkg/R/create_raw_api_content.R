#' Get Raw API Content
#'
#' Get Raw API Content from alphavantage
#'
#' @param symbol character object, ticker name
#' @param api_fun character object, api function defined by alphavantage
#' @param api_key character object, api key from alphavantage
#' @param data_type character object, either json or csv
#' @return raw content from alphavantage API
#' @importFrom stringr str_c
#' @importFrom glue glue
#' @importFrom readr read_csv
#' @importFrom jsonlite fromJSON
#' @import dplyr
#' @import httr
#' @export
get_raw_api_content <- function(symbol,
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

  # Get raw API content
  ua <- httr::user_agent("https://github.com/business-science")

  response <- httr::GET(url, ua)

  # Extract raw content
  content_type <- httr::http_type(response)

  content <- httr::content(response, as = "text", encoding = "UTF-8")

  content_list <- content %>% jsonlite::fromJSON()

  return(content_list)


}

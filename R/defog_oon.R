#' Download and Parse TiC Out-of-Network JSON urls
#'
#' @param url url from third-party-payer's
#' machine-readable Transparency-in-Coverage filings,
#' specifically for Out-of-Network (OON) plans;
#' also referred to as "Allowed Amounts" in the URLs
#'
#' @return A tibble containing information regarding
#' health insurance plans' allowed amounts for
#' out-of-network procedures performed by
#' healthcare providers.
#'
#' @export
#'
#' @examples
#' \dontrun{defog_oon(oon_url_ex)}

defog_oon <- function(url) {

  # Check internet connection
  attempt::stop_if_not(
    curl::has_internet() == TRUE,
    msg = "Please check your internet connection.")

  # Create polite version
  polite_req <- polite::politely(
    httr2::request,
    verbose = FALSE,
    delay = 2)

  # Create request
  req <- polite_req(url)

  # Send and save response
  resp <- req |>
    httr2::req_throttle(50 / 60) |>
    httr2::req_perform()

  # Parse JSON response and save results
  content <- resp |> httr2::resp_body_json(
    check_type = FALSE,
    simplifyVector = TRUE)

  # Clean Results
  results <- content$out_of_network |>
    tidyr::unnest(allowed_amounts) |>
    tidyr::unnest(service_code) |>
    tidyr::unnest(payments) |>
    tidyr::unnest(providers) |>
    tidyr::unnest(tin) |>
    dplyr::rename(ein = value) |>
    dplyr::select(!(type)) |>
    tidyr::unnest(npi) |>
    dplyr::mutate(npi = (as.character(npi)))

  return(results)

}

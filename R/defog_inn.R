#' Download and Parse TiC In-Network JSON urls
#'
#' @param url url from third-party-payer's
#' machine-readable Transparency-in-Coverage filings,
#' specifically for In-Network plans
#'
#' @return A tibble containing information regarding
#' health insurance plans' negotiated rates for
#' in-network procedures performed by healthcare providers.
#'
#' @export
#'
#' @examples
#' \dontrun{defog_inn(inn_url_ex)}

defog_inn <- function(url) {

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
  results <- content$in_network |>
    tidyr::unnest(negotiated_rates) |>
    tidyr::unnest(negotiated_prices) |>
    tidyr::unnest(service_code) |>
    tidyr::unnest(billing_code_modifier) |>
    tidyr::unnest(provider_groups) |>
    tidyr::unnest(tin) |>
    dplyr::rename(ein = value) |>
    dplyr::select(!(type)) |>
    tidyr::unnest(npi)

  return(results)

}

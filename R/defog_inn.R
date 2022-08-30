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

  # Create Location Key
  location <- url

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

  # Create results df
  results <- content$in_network

  # Test for empty INN lists
  if (insight::is_empty_object(results) == TRUE) {

    results <- tibble::tibble(
      negotiation_arrangement = NA,
      name = NA,
      billing_code_type = NA,
      billing_code_type_version = NA,
      billing_code = NA,
      description = NA,
      negotiated_type = NA,
      negotiated_rate = as.integer(0.00),
      expiration_date = NA,
      service_code = NA,
      billing_class = NA,
      additional_information = NA,
      billing_code_modifier = NA,
      ein = NA,
      npi = NA
    )

  } else {

  # Clean Results
  results <- results |>
    tidyr::unnest(negotiated_rates) |>
    tidyr::unnest(negotiated_prices) |>
    tidyr::unnest(service_code) |>
    tidyr::unnest(billing_code_modifier) |>
    tidyr::unnest(provider_groups) |>
    tidyr::unnest(tin) |>
    dplyr::rename(ein = value) |>
    dplyr::select(!(type))

  # Deal with NPI list
  results <- results |>
    tidyr::unnest_wider(npi,
                        names_sep = "_",
                        simplify = TRUE) |>
    tidyr::pivot_longer(cols = dplyr::starts_with("npi"),
                        names_to = "npi_no",
                        values_to = "npi",
                        values_drop_na = TRUE) |>
    dplyr::select(!(npi_no)) |>
    dplyr::mutate(npi = (as.character(npi)))

  }

  # Add location URL
  results <- results |>
    dplyr::mutate(location = url)

  return(results)

}

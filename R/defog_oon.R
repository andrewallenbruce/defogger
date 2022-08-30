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
  results <- content$out_of_network

  # Test for empty OON lists
  if (insight::is_empty_object(results) == TRUE) {

    results <- tibble::tibble(
      name = NA,
      billing_code_type = NA,
      billing_code_type_version = NA,
      billing_code = NA,
      description = NA,
      ein = NA,
      service_code = NA,
      billing_class = NA,
      allowed_amount = as.integer(0.00),
      billed_charge = as.integer(0.00),
      npi = NA
    )

  } else {

    # Clean Results
    results <- results |>
      tidyr::unnest(allowed_amounts) |>
      tidyr::unnest(service_code) |>
      tidyr::unnest(payments) |>
      tidyr::unnest(providers) |>
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

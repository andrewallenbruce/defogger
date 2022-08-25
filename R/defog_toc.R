#' Download and Parse TiC TOC urls
#'
#' @param url url from a third-party-administrator's (TPA)
#' machine-readable Transparency-in-Coverage (TiC) filings
#' containing the Table of Contents (TOC) of plans.
#'
#' @return A tibble containing the TPA's list of insurance plan
#' names, plan ID, ID type, market type(individual or group),
#' the parent entity, rate type (in-network or out-of-network),
#' and url location of each rate type's file.
#'
#' @export
#'
#' @examples
#' defog_toc(tic_toc_url_ex)

defog_toc <- function(url) {

  # Check for data input
  if (missing(url))
    stop("You haven't input a URL.")

  # Check internet connection
  attempt::stop_if_not(curl::has_internet() == TRUE,
                       msg = "Please check your internet connection.")

  # Create polite version
  polite_req <- polite::politely(httr2::request,
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

  # Content Reporting Structure data frame
  content_report <- content$reporting_structure

  # Unnest In-Network Files
  if (sum(stringr::str_count(
    names(content_report), "in_network_files")) >= 1) {
    results <- content_report |>
      tidyr::unnest(in_network_files) |>
      dplyr::select(!("description")) |>
      dplyr::rename(in_network = location)

  } else {
    results <- content_report
  }

  # Unnest Out-of-Network Files
  if (sum(stringr::str_count(
    names(content_report), "allowed_amount_file")) >= 1) {
    results <- results |>
      tidyr::unnest(allowed_amount_file) |>
      dplyr::select(!("description")) |>
      dplyr::rename(out_of_network = location)

  } else {
    results
  }

  # Assign Row ID and Parent Entity Name
  results <- results |>
    tibble::rowid_to_column(var = "id") |>
    dplyr::mutate(entity = content$reporting_entity_name)

  # Unnest Reporting Plans
  results <- results |> tidyr::unnest(reporting_plans)

  # Pivot Longer
  if (sum(stringr::str_count(
    names(content_report), "allowed_amount_file")) >= 1) {
    results <- results |> tidyr::pivot_longer(
      cols = in_network:out_of_network,
      names_to = "rate_type",
      values_to = "location"
    ) |>
      dplyr::filter(!is.na(location))

  } else {
    results <- results |>
      tidyr::pivot_longer(
        cols = in_network,
        names_to = "rate_type",
        values_to = "location") |>
      dplyr::filter(!is.na(location))
  }

  return(results)

}

#' Tidy NPI NPPES Search Data
#'
#' @param df data.frame or tbl_df, response from prov_nppes_npi()
#'
#' @return A tibble containing the NPI(s) searched for on the
#' NPPES, the date-time of the search, and the unnested and
#' tidied list-columns of results split into groups.
#'
#' @export
#'
#' @examples
#' \dontrun{defog_npi_wide(nppes_npi_response)}

defog_npi_wide <- function(df) {

  # Check for data input
  if (missing(df)) stop("You haven't input a data frame.")

  # Handle any ERROR returns
  if (nrow(df |> dplyr::filter(outcome == "Errors")) >= 1) {

    errors <- df |>
      dplyr::filter(outcome == "Errors") |>
      tidyr::unnest(data_lists) |>
      dplyr::rename(id = search) |>
      dplyr::mutate(id = as.numeric(id)) |> ########### Numeric?
      dplyr::mutate(group = "error",
                    description = "nppes_npi",
                    field = "deactivated") |>
      dplyr::select(id, datetime, group, description, field)

    # Bind rows
    results <- errors

  } else {

    # Start with base df and unnest first level
    start <- df |>
      dplyr::filter(outcome == "results") |>
      tidyr::unnest(data_lists)

    # Isolate the NPI and datetime
    search <- start |>
      dplyr::select(search:datetime) |>
      dplyr::mutate(id = search) |>
      dplyr::select(id, datetime)

    ## || CREATE ID KEY
    key <- search |>
      dplyr::select(id) |>
      unlist(use.names = FALSE)

    # Rename number & enumeration type / pivot long
    basic_1 <- start |>
      dplyr::select(
        prov_type = enumeration_type,
        nppes_npi = number) |>
      dplyr::mutate(group = "basic",
                    nppes_npi = as.character(nppes_npi)) |>
      dplyr::mutate(id = key) |>
      tidyr::pivot_longer(!c(group, id),
                          names_to = "description",
                          values_to = "field") |>
      dplyr::relocate(id)

    # Basic section / pivot long
    basic_2 <- start |>
      dplyr::select(basic) |>
      tidyr::unnest(basic) |>
      dplyr::mutate(group = "basic") |>
      dplyr::mutate(id = key) |>
      tidyr::pivot_longer(!c(group, id),
                          names_to = "description",
                          values_to = "field") |>
      dplyr::relocate(id)

    # Bind rows
    results <- dplyr::bind_rows(basic_1, basic_2)

    # Isolate lists / remove if empty
    lists <- start |>
      dplyr::select(!(basic)) |>
      dplyr::select(
        where(~ is.list(.x) && (
          insight::is_empty_object(.x) == FALSE))) |>
      dplyr::mutate(id = key)

    # List names for identification
    ls_names <- tibble::enframe(names(lists))

    # Addresses section / pivot long
    if (nrow(ls_names |> dplyr::filter(value == "addresses")) >= 1) {

      addresses <- lists |>
        dplyr::select(id, addresses) |>
        tidyr::unnest(cols = c(addresses)) |>
        tidyr::pivot_longer(!c(id, address_purpose),
                            names_to = "description",
                            values_to = "field") |>
        dplyr::rename(group = address_purpose) |>
        dplyr::mutate(group = tolower(group))

      # Bind rows
      results <- dplyr::bind_rows(results, addresses)

    } else {
      invisible("No Addresses")
    }

    # Taxonomies section / pivot long
    if (nrow(ls_names |> dplyr::filter(value == "taxonomies")) >= 1) {

      taxonomies <- lists |>
        dplyr::select(id, taxonomies) |>
        tidyr::unnest(cols = c(taxonomies)) |>
        dplyr::mutate(group = "taxonomies") |>
        dplyr::mutate(primary = as.character(primary)) |>
        tidyr::pivot_longer(!c(id, group),
                            names_to = "description",
                            values_to = "field")

      # Bind rows
      results <- dplyr::bind_rows(results, taxonomies)

    } else {
      invisible("No Taxonomies")
    }

    # Identifiers section / pivot long
    if (nrow(ls_names |> dplyr::filter(value == "identifiers")) >= 1) {

      identifiers <- lists |>
        dplyr::select(id, identifiers) |>
        tidyr::unnest(cols = c(identifiers)) |>
        dplyr::mutate(group = "identifiers") |>
        tidyr::pivot_longer(!c(id, group),
                            names_to = "description",
                            values_to = "field")

      # Bind rows
      results <- dplyr::bind_rows(results, identifiers)

    } else {
      invisible("No Identifiers")
    }

    # Other Names section / pivot long
    if (nrow(ls_names |> dplyr::filter(value == "other_names")) >= 1) {

      other_names <- lists |>
        dplyr::select(id, other_names) |>
        tidyr::unnest(cols = c(other_names)) |>
        dplyr::mutate(group = "other names") |>
        tidyr::pivot_longer(!c(id, group),
                            names_to = "description",
                            values_to = "field")

      # Bind rows
      results <- dplyr::bind_rows(results, other_names)

    } else {
      invisible("No Other Names")
    }

    # Practice Locations section / pivot long
    if (nrow(ls_names |> dplyr::filter(value == "practiceLocations")) >= 1) {

      practiceLocations <- lists |>
        dplyr::select(id, practiceLocations) |>
        tidyr::unnest(cols = c(practiceLocations)) |>
        dplyr::mutate(group = "practice locations") |>
        tidyr::pivot_longer(!c(id, group),
                            names_to = "description",
                            values_to = "field")

      # Bind rows
      results <- dplyr::bind_rows(results, practiceLocations)

    } else {
      invisible("No Practice Locations")
    }

    # Endpoints section / pivot long
    if (nrow(ls_names |> dplyr::filter(value == "endpoints")) >= 1) {

      endpoints <- lists |>
        dplyr::select(id, endpoints) |>
        tidyr::unnest(cols = c(endpoints)) |>
        dplyr::mutate(group = "endpoints") |>
        tidyr::pivot_longer(!c(id, group),
                            names_to = "description",
                            values_to = "field")

      # Bind rows
      results <- dplyr::bind_rows(results, endpoints)

    } else {
      invisible("No Endpoints")
    }
    # Final Join
    results <- dplyr::inner_join(search, results, by = "id")

    # If NPI Type-2, create Authorized Official group
    if (sum(stringi::stri_count_fixed(results$description, "authorized")) >= 1) {

      results <- results |>
        dplyr::mutate(group = ifelse(
          stringr::str_detect(description, "authorized\\sofficial\\s"),
          stringr::str_match(description, "authorized\\sofficial"), group),
          description = ifelse(stringr::str_detect(description, "authorized\\sofficial\\s"),
                               stringr::str_match(description, "authorized\\sofficial\\s(.*)")[, 2], description))

    } else {

      invisible("NPI Type-1")

    }


  }
  return(results)
}

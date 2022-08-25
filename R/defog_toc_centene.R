#' Centene: Add Reporting Entity & the Sub-Entity
#'
#' @param df data frame from Centene TOC link
#'
#' @return A tibble adding the reporting entity's name
#' and the sub-entity's name.
#'
#' @export
#'
#' @examples
#' defog_toc_centene(centene_toc_ex)

defog_toc_centene <- function(df) {

  results <- df |>
    dplyr::mutate(state = dplyr::if_else(
      stringr::str_detect(location, "ambetter-(.*)_"),
      stringr::str_match(location, "ambetter-(.*)_")[, 2], "NA")) |>
    dplyr::mutate(state = stringr::str_to_upper(state)) |>
    dplyr::mutate(state = dplyr::case_when(
      state == "NC-WELLCARE" ~ "NC",
      TRUE ~ state)) |>
    dplyr::mutate(sub_entity = stringr::str_match(
      location, "(magellan|ambetter)")[, 2]) |>
    dplyr::mutate(sub_entity = stringr::str_to_title(sub_entity)) |>
    dplyr::relocate(id, state, entity, sub_entity)

  return(results)
}

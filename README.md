
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `defogger` <a href="https://andrewallenbruce.github.io/defogger/"><img src="man/figures/logo.svg" align="right" height="200"/></a>

> Streamlined Workflow for Transparency in Coverage (TiC) Data Analysis

<!-- badges: start -->

[![R-CMD-check](https://github.com/andrewallenbruce/defogger/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/defogger/actions/workflows/R-CMD-check.yaml)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![repo status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
[![code
size](https://img.shields.io/github/languages/code-size/andrewallenbruce/defogger.svg)](https://github.com/andrewallenbruce/defogger)
[![last
commit](https://img.shields.io/github/last-commit/andrewallenbruce/defogger.svg)](https://github.com/andrewallenbruce/defogger/commits/main)
[![Codecov test
coverage](https://codecov.io/gh/andrewallenbruce/defogger/branch/main/graph/badge.svg)](https://app.codecov.io/gh/andrewallenbruce/defogger?branch=main)
<!-- badges: end -->

<br><br>

## Installation

You can install the development version of `defogger` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andrewallenbruce/defogger")

# install.packages("remotes")
remotes::install_github("andrewallenbruce/defogger")
```

``` r
# Load library
library(defogger)
```

<br>

## Defogging Transparency in Coverage Files

<br>

The [Transparency in Coverage Final
Rule](https://www.cms.gov/newsroom/fact-sheets/transparency-coverage-final-rule-fact-sheet-cms-9915-f)\[^2\]
requires most group health plans and issuers of group or individual
health insurance to disclose pricing information in the form of
machine-readable files containing the following sets of costs for items
and services:

<br>

- **In-Network Rate File:** Rates for all covered items and services
  between the plan or issuer and in-network providers.

<br>

- **Allowed Amount File:** Allowed amounts for, and billed charges from,
  out-of-network providers.

<br>

## Usage

``` r
res <- httr2::request("https://transparency-in-coverage.uhc.com/api/v1/uhc/blobs/") |> 
       httr2::req_perform() |> 
       httr2::resp_body_json(check_type = FALSE, 
                             simplifyVector = TRUE)

res$blobs |> 
  tibble::tibble() |> 
  dplyr::slice_tail() |> 
  dplyr::glimpse()
#> Rows: 1
#> Columns: 2
#> $ name        <chr> "2023-01-01_totes-Isotoner_index.json"
#> $ downloadUrl <chr> "https://uhc-tic-mrf.azureedge.net/public-mrf/2023-01-01/2…
```

<br><br>

``` r
dl <- res$blobs |> tibble::tibble() |> dplyr::slice_tail()

dll <- httr2::request(dl$downloadUrl) |> 
       httr2::req_perform() |> 
       httr2::resp_body_json(check_type = FALSE, simplifyVector = TRUE)

dll$reporting_structure |> 
  tidyr::unnest(cols = c(reporting_plans, in_network_files)) |> 
  dplyr::glimpse()
#> Rows: 2
#> Columns: 6
#> $ plan_name        <chr> "POS CHOICE PLUS", "POS CHOICE PLUS"
#> $ plan_id          <chr> "310405270", "310405270"
#> $ plan_id_type     <chr> "EIN", "EIN"
#> $ plan_market_type <chr> "group", "group"
#> $ description      <chr> "in-network files", "in-network files"
#> $ location         <chr> "https://uhc-tic-mrf.azureedge.net/public-mrf/2023-01…
```

<br><br>

``` r
dll$reporting_structure |> 
  tidyr::unnest(cols = c(reporting_plans, in_network_files)) |> 
  purrr::pluck("location", 1)
#> [1] "https://uhc-tic-mrf.azureedge.net/public-mrf/2023-01-01/2023-01-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PPO---NDC_PPO-NDC_in-network-rates.json.gz"
```

<br>

``` r
dll$reporting_structure |> 
  tidyr::unnest(cols = c(reporting_plans, in_network_files)) |> 
  purrr::pluck("location", 2)
#> [1] "https://uhc-tic-mrf.azureedge.net/public-mrf/2023-01-01/2023-01-01_United-HealthCare-Services--Inc-_Third-Party-Administrator_PS1-50_C2_in-network-rates.json.gz"
```

<br><br>

``` r
centene_toc_jun <- "https://www.centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-06-29_ambetter_index.json"
centene_toc_sep <- "https://www.centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-09-30_ambetter_index.json"
centene_toc_dec <- "https://www.centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_ambetter_index.json"
```

<br>

``` r
defog_toc(centene_toc_dec) |> 
  dplyr::select(!c(id, 
                   plan_id_type, 
                   plan_market_type, 
                   entity)) |> 
  dplyr::slice_head() |> 
  dplyr::glimpse()
#> Rows: 1
#> Columns: 5
#> $ plan_name <chr> "Silver 87 Ambetter HMO "
#> $ plan_id   <chr> "67138CA052"
#> $ rate_type <chr> "in_network"
#> $ location  <chr> "http://centene.com/content/dam/centene/Centene%20Corporate/…
#> $ origin    <chr> "https://www.centene.com/content/dam/centene/Centene%20Corpo…
```

<br>

# Out-of-Network Files

``` r
defog_toc(centene_toc_dec) |> 
  dplyr::filter(rate_type == "out_of_network") |> 
  dplyr::select(location) |> 
  dplyr::distinct() |> 
  tibble::deframe()
#>  [1] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ca_allowed-amounts.json"
#>  [2] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-la_allowed-amounts.json"
#>  [3] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ky_allowed-amounts.json"
#>  [4] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ms_allowed-amounts.json"
#>  [5] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-pa_allowed-amounts.json"
#>  [6] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-wa_allowed-amounts.json"
#>  [7] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-tn_allowed-amounts.json"
#>  [8] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-mo_allowed-amounts.json"
#>  [9] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-az_allowed-amounts.json"
#> [10] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ok_allowed-amounts.json"
#> [11] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nc_allowed-amounts.json"
#> [12] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nh_allowed-amounts.json"
#> [13] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-sc_allowed-amounts.json"
#> [14] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ne_allowed-amounts.json"
#> [15] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nv_allowed-amounts.json"
#> [16] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nj_allowed-amounts.json"
#> [17] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nm_allowed-amounts.json"
#> [18] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-in_allowed-amounts.json"
#> [19] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ga_allowed-amounts.json"
#> [20] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-il_allowed-amounts.json"
#> [21] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ar_allowed-amounts.json"
#> [22] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-fl_allowed-amounts.json"
#> [23] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ks_allowed-amounts.json"
#> [24] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-tx_allowed-amounts.json"
#> [25] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-oh_allowed-amounts.json"
#> [26] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-mi_allowed-amounts.json"
```

<br>

``` r
centene_oon <- defog_toc(centene_toc_dec) |> 
  dplyr::filter(rate_type == "out_of_network") |> 
  dplyr::select(location) |> 
  dplyr::distinct()

defog_oon(tibble::deframe(centene_oon[10, ])) |> 
  dplyr::select(npi, billing_code, name, allowed_amount, billed_charge) |> 
  knitr::kable()
```

| npi        | billing_code | name                         | allowed_amount | billed_charge |
|:-----------|:-------------|:-----------------------------|---------------:|--------------:|
| 1649794157 | 250          | PHARMACY                     |         713.41 |         43.25 |
| 1043260482 | 300          | LABORATORY                   |         256.32 |        651.00 |
| 1578704938 | 301          | LAB/CHEMISTRY                |         707.77 |       1905.00 |
| 1649794157 | 301          | LAB/CHEMISTRY                |        6312.15 |      10520.25 |
| 1649794157 | 301          | LAB/CHEMISTRY                |         693.83 |       4166.00 |
| 1649794157 | 301          | LAB/CHEMISTRY                |        6312.15 |      10520.25 |
| 1649794157 | 301          | LAB/CHEMISTRY                |         693.83 |       4166.00 |
| 1144228487 | 301          | LAB/CHEMISTRY                |        2070.71 |       4547.94 |
| 1164494027 | 301          | LAB/CHEMISTRY                |         311.40 |        865.00 |
| 1164494027 | 301          | LAB/CHEMISTRY                |         147.35 |       1320.00 |
| 1164494027 | 301          | LAB/CHEMISTRY                |         311.40 |        865.00 |
| 1164494027 | 301          | LAB/CHEMISTRY                |         147.35 |       1320.00 |
| 1376561944 | 301          | LAB/CHEMISTRY                |         254.40 |        634.10 |
| 1144228487 | 636          | DRUG/DETAIL CODE             |         114.97 |        732.38 |
| 1689337503 | 98940        | CHIROPRACT MANJ 1-2 REGIONS  |         371.84 |        910.00 |
| 1659667798 | 98940        | CHIROPRACT MANJ 1-2 REGIONS  |        1832.40 |       3900.00 |
| 1740207646 | A0425        | GRND MLGE PER STATUTE MILE   |         123.69 |        361.00 |
| 1234567893 | E2402        | NEG PRSS WND TX PUMP STATN   |         664.95 |       2407.90 |
| 1234567893 | S9502        | HIT ABX ANTIVIRL/ANTIFUNGAL; |         240.00 |       3696.18 |

<br><br>

# In-Network Files

<br>

``` r
defog_toc(centene_toc_dec) |> 
  dplyr::filter(rate_type == "in_network") |> 
  dplyr::select(location) |> 
  dplyr::distinct() |> 
  tibble::deframe()
#>  [1] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ca_in-network.json"
#>  [2] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-la_in-network.json"
#>  [3] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ky_in-network.json"
#>  [4] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ms_in-network.json"
#>  [5] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-pa_in-network.json"
#>  [6] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-wa_in-network.json"
#>  [7] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-tn_in-network.json"
#>  [8] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-mo_in-network.json"
#>  [9] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-az_in-network.json"
#> [10] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ok_in-network.json"
#> [11] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nc_in-network.json"
#> [12] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nh_in-network.json"
#> [13] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-sc_in-network.json"
#> [14] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ne_in-network.json"
#> [15] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nv_in-network.json"
#> [16] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nj_in-network.json"
#> [17] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-nm_in-network.json"
#> [18] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-in_in-network.json"
#> [19] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ga_in-network.json"
#> [20] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-il_in-network.json"
#> [21] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ar_in-network.json"
#> [22] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-fl_in-network.json"
#> [23] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-ks_in-network.json"
#> [24] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-tx_in-network.json"
#> [25] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-oh_in-network.json"
#> [26] "http://centene.com/content/dam/centene/Centene%20Corporate/json/DOCUMENT/2022-12-29_centene-management-company-llc_ambetter-mi_in-network.json"
```

<br>

``` r
centene_inn <- defog_toc(centene_toc_dec) |> 
  dplyr::filter(rate_type == "in_network") |> 
  dplyr::select(location) |> 
  dplyr::distinct()

defog_inn(tibble::deframe(centene_inn[10, ])) |> 
  dplyr::slice_head(n = 30) |> 
  dplyr::select(npi,
                billing_code,
                billing_code_modifier,
                name, 
                negotiated_rate) |> 
  knitr::kable()
```

| npi        | billing_code | billing_code_modifier | name                       | negotiated_rate |
|:-----------|:-------------|:----------------------|:---------------------------|----------------:|
| 1518136126 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1407266083 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1538684428 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1669910949 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1912080888 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1730327446 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1073696043 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1740427178 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1265437909 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1861540858 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1265702062 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1053646802 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1518136126 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1407266083 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1457350142 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1841607264 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1538684428 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1669910949 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1861961112 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1124048772 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1699127050 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1477573020 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1326044603 | 00142        | QZ                    | ANESTH, LENS SURGERY       |          130.31 |
| 1518136126 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |
| 1407266083 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |
| 1538684428 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |
| 1669910949 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |
| 1912080888 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |
| 1730327446 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |
| 1073696043 | 00145        | QZ                    | ANESTH, VITREORETINAL SURG |          208.50 |

<br>

## Code of Conduct

Please note that the `defogger` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/defogger/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

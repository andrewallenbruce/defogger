
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `defogger` <a href="https://andrewallenbruce.github.io/defogger/"><img src="man/figures/logo.svg" align="right" height="500"/></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/andrewallenbruce/defogger/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/defogger/actions/workflows/R-CMD-check.yaml)
[![repo status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://choosealicense.com/licenses/mit/)

<!-- badges: end -->

[{defogger}](https://github.com/andrewallenbruce/defogger/) is a package
aimed at providing a collection of open-source tools for streamlining
the analysis workflow of Transparency in Coverage (TiC) files.

## Transparency in Coverage

> *Health plan price transparency helps consumers know the cost of a
> covered item or service before receiving care. Beginning July 1, 2022,
> most group health plans and issuers of group or individual health
> insurance will begin posting pricing information for covered items and
> services. This pricing information can be used by third parties, such
> as researchers and app developers to help consumers better understand
> the costs associated with their health care. More requirements will go
> into effect starting on January 1, 2023, and January 1, 2024 which
> will provide additional access to pricing information and enhance
> consumers’ ability to shop for the health care that best meet their
> needs.*[^1]

The [Transparency in Coverage Final
Rule](https://www.cms.gov/newsroom/fact-sheets/transparency-coverage-final-rule-fact-sheet-cms-9915-f)[^2]
requires most group health plans and issuers of group or individual
health insurance to disclose pricing information in the form of
machine-readable files containing the following sets of costs for items
and services:

-   **In-Network Rate File:** Rates for all covered items and services
    between the plan or issuer and in-network providers.
-   **Allowed Amount File:** Allowed amounts for, and billed charges
    from, out-of-network providers.

<br>

### A Unique Opportunity

[CMS.gov](https://www.cms.gov/) describes the situation perfectly:

> With the data contained in the machine-readable files from plans and
> issuers, third party developers will be able to create much more
> advanced and accurate price transparency tools. These tools will help
> inform consumers, as well as the broader public, about patterns in
> health care costs and will offer immense opportunities for innovation.

<br>

> Making price transparency information publicly available strengthens
> the work of other health care stakeholders that help provide care or
> promote access to care to consumers, or otherwise aim to protect
> consumers and their interests in the health care system. These
> entities include researchers, regulators, lawmakers, patient and
> consumer advocates, and businesses that provide consumer support tools
> and services. A key aspect of Transparency in Coverage is to make
> health care pricing information more accessible and useful to
> consumers by making the information available to persons and entities
> with the requisite experience and expertise to assist individual
> consumers and other health care purchasers to make informed health
> care decisions.

<br>

> With information on pricing, these other health care stakeholders can
> better fulfill each of the unique roles they play to improve America’s
> health care system for consumers. For instance, with pricing
> information, researchers could better assess the cost-effectiveness of
> various treatments; state regulators could better review issuers’
> proposed rate increases; patient advocates could better help guide
> patients through care plans; employers could adopt incentives for
> consumers to choose more cost-effective care; and entrepreneurs could
> develop tools that help doctors better engage with patients.

## Installation

You can install the development version of {defogger} from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andrewallenbruce/defogger")
```

## Usage

Read the [overview](articles/defogger.html) for an introduction to the
basic functionality.

## Code of Conduct

Please note that the defogger project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/defogger/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://www.cms.gov/healthplan-price-transparency>

[^2]: The final rule can be found here:
    <https://www.cms.gov/CCIIO/Resources/Regulations-and-Guidance/Downloads/CMS-Transparency-in-Coverage-9915F.pdf>

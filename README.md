# openarchaeoCollaboration

This [research compendium](https://research-compendium.science/) contains the data and code for ...

## Usage

This compendium is an R package.
The main analysis is described in `analysis/paper.html`, which is generated from `analysis/paper.Rmd`.

To reproduce the analysis yourself:

1. Download or clone the latest version of this repository
2. Build and install the package with `devtools::build()` (or `Ctrl+Shift+B` in RStudio)
3. Run the code chunks in `analysis/paper.Rmd`

You will need to set up a personal access token (PAT) to access the GitHub API:

```r
usethis::create_github_token()
```

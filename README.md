# Open archaeology: a survey of collaborative software engineering in archaeological research

Zack Batist, University of Toronto  
Joe Roe, University of Bern  

This [research compendium](https://research-compendium.science/) contains the data and code for our analysis of the state of the art in archaeological software engineering, using the list compiled at [open-archaeo](https://open-archaeo.info/).

Preliminary results were presented at the [CAA2021 Virtual Conference](https://2021.caaconference.org/) hosted by the Cyprus Institute of Technology, in *[S17, Tools for the Revolution: developing packages for scientific programming in archaeology?](https://sslarch.github.io/sessions/sessioni/)*, a session organised by the special interest group for scientific scripting languages.

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

## Citation

Please cite the preliminary results presented at CAA as:

* Batist, Zack and Joe Roe. 2021. *Open archaeology: a survey of collaborative software engineering in archaeological research*. Presented at Computer Applications & Quantitative Methods in Archaeology, Limassol (Virtual), 14–18 June 2021.

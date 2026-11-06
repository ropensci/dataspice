# NEWS

## dataspice 1.2.1

NEW

- `build_site()` has a new `static_map` argument that renders the spatial coverage as a self-contained static map image instead of the default Leaflet map. A companion `static_map_method` argument controls how the map projection is chosen: a built-in extent-aware equal-area method (`"default"`), `"crsuggest"`, `"equalearth"`, or a custom PROJ string. Both arguments are experimental. (#123, #126)
- `build_site()` now displays a text description of the spatial coverage above the map, which is useful if the map fails to load. (#125)

CHANGED

- The HTML template now includes a `DOCTYPE` declaration and a `lang` attribute. (#124)

## dataspice 1.1.1

This release updates dataspice's tests to be compatible with the upcoming stringr 1.6.0 release.

## dataspice 1.1.0

This release is for the version of the package after going through [rOpenSci Onboarding](https://github.com/ropensci/software-review/issues/426).
No breaking user-facing changes were made.

NEW

- `dataspice` helpfully now has a help page: `?dataspice`

CHANGED

- Test coverage dramatically increased
- Various documentation (README, vignettes, help pages) now much more consistent

## dataspice 1.0.0

Initial CRAN release

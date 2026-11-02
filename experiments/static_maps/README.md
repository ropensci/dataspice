# Experiment: static_maps

Experiment for solutions to [#123: problem with map visualisation](https://github.com/ropensci/dataspice/issues/123).

In [#123](https://github.com/ropensci/dataspice/issues/123), the issue author reported a problem with the dynamic [Leaflet](https://leafletjs.com)-based map the dataspice HTML report produces where tiles wouldn't load. This is caused by a fundemental limitation in Leaflet and has to do with usage terms on the [OpenStreetMap](https://www.openstreetmap.org/#map=9/48.041/-123.426) tiles Leaflet uses. The issue contains more detail but the best solution for dataspice users who want dataspice HTML that doesn't have this issue is for us to have an option to build a static variant of the map. We might even consdier making the static map the default but that's another issue for another day.

The code in this folder was generated with `gpt-6-luna` but the text was written by me.

## Summary

Producing a static map for an arbitrarily sized and positioned bounding box is not an easily or totally solvable problem because map projection is hard. We can either use a fixed projection for all bounding boxes or use a dynamic projection based on the bounding box. To see how this could work for our new static maps feature, this experiment:

1. Creates 10 example bounding boxes (`test-bboxes.csv`) to give us some example data to test any rendering method with
2. Defines four different rendering methods to test the bounding boxes in (1)
3. Creates a static HTML playground where I can play with them to find a suitable default method

## Quickstart

This requires R and the `pak` and `renv` packages.

From an R Console, run:

```r
install.packages(c("renv", "pak"))
```

Then in a terminal, run:

```bash
Rscript inst/scripts/projection-comparison.R
```

If you use [`just`](https://just.systems), you can just run `just`.

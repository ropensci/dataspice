## Tested on

- macOS 10.15.3, R 3.6.2

## R CMD check

0 errors, 0 warnings, 1 note

```
> checking R code for possible problems ... NOTE
  es_creators : <anonymous>: no visible binding for global variable
    ‘givenName’
  es_creators : <anonymous>: no visible binding for global variable
    ‘familyName’
  Undefined global functions or variables:
    familyName givenName
```

This is due to our use of dplyr in the package code and can safely be ignored.

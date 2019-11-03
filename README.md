# robb.swift

My personal website, ported from Jekyll to Swift.

#### Before:

```
$ time bundle exec jekyll build
Configuration file: /Users/robb/projects/robb.is/_config.yml
            Source: /Users/robb/projects/robb.is
       Destination: /Users/robb/projects/robb.is/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 2.013 seconds.
 Auto-regeneration: disabled. Use --watch to enable.
        2.79 real         1.93 user         0.43 sys
```

#### After

```
$ time swift run robb.swift build
Building site
        0.31 real         0.73 user         0.19 sys
```

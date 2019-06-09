---
color: 78CA93
date: 2013-01-31T00:00:00Z
link: http://www.cimgf.com/2013/01/29/down-with-magic-strings/
title: Down with Magic Strings!
category: ❤ing
slug: down-with-magic-strings
---

[I recently linked to KSImageNamed][ksimagenamed] as a solution to the issue of
auto-completion and of image resources. Today I came across Patrick Hughes'
[script to generate image aliases as part of the build process][script].

> Each time it runs it scans a folder for images. It then compares the image
> names to collect the various platform specific and scaled versions and groups
> them together. It then #defines a block for each group that loads the image
> using imageNamed:, throws an assertion if the image doesn't load and then
> returns the image.

I think I like this one even better, since it also validates the the image
resources and points out missing Retina or iPad assets where appropriate.

Cocoa is unfortunately fairly [stringly typed][stringly-typing] and the more we
enforce at compile-time, the fewer errors can happen at run-time.

[ksimagenamed]: /❤ing/ksimagenamed
[script]: https://gist.github.com/4462966
[stringly-typing]: http://www.codinghorror.com/blog/2012/07/new-programming-jargon.html

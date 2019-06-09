---
color: 338888
date: 2013-05-24T00:00:00Z
link: http://floriankugler.com/blog/2013/5/24/layer-trees-vs-flat-drawing-graphics-performance-across-ios-device-generations
title: Layer Trees vs. Flat Drawing
category: ❤ing
slug: layer-trees-vs-flat-drawing
---

[Florian][florian] did some interesting measurements of drawing performances
across multiple device generations.

> In this article I will present the results of a simple benchmark I performed
> on the iPhone 3G, 4, 4S and 5 as well as the iPad 3, iPad mini and iPad 4.

He compared the performance of trees of UIViews and CALayers as well as flat
bitmaps drawn with CoreGraphics.

Since CoreGraphics drawing is done on the CPU, it comes to no surprise that
retina devices face bigger performance challenges.

> The iPhone 5 is the first device which is able beat the iPhone 3GS (!) in
> terms of Core Graphics drawing performance in this example.

Also:

> The iPad 3 really stands out in this comparison. It just has abysmally bad
> drawing performance. The retina display is great, but the hardware was clearly
> not ready for it yet.

Since the iPad 3 is likely being supplied with iOS updates for at least another
year, it's an important one to keep around has a test device since it couples
a retina screen with a comparatively underpowered CPU.

[florian]: http://floriankugler.com

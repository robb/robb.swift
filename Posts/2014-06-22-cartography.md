---
color: EE9C44
date: 2014-06-22T00:00:00Z
description: Declarative Auto Layout in Swift
link: https://github.com/robb/Cartography
project: true
title: Cartography
category: working-on
slug: cartography
---

If you follow the Apple developer community, you've probably heard of [Swift] by
now, Apple's new programming language for iOS and OS X apps.

Some of Swift's features, such as operator overloading and implicit closures
allow us to create powerful yet typesafe DSLs. For example, I recently released
my first Swift open source library, [Cartography], that makes use of both of
these features.

Inspired by the awesome [FLKAutoLayout], Cartography allows you to create Auto
Layout constraints in a declarative fashion.

While `NSLayoutConstraint` supports what they call a _visual format string_, its
syntax is not very intuitive. Additionally, since it is, well, a string, the
compiler can't assist you with validating your expression either. Compare this
example I adapted from Apple's documentation

```objc
NSArray *constraint = [NSLayoutConstraint
    constraintsWithVisualFormat:@"[view1]-20-[view2]"
    options:0
    metrics:nil
    views:NSDictionaryOfVariableBindings(view1, view2)];

[view2 addConstraint:constraint];
```

with the equivalent Cartography code:

```swift
layout(view1, view2) { view1, view2 in
    view2.left == view1.right + 20
}
```

Fixed aspect ratios can't even be expressed using the visual format string, you would have to use the lower level `+constraintWithItem:`​<wbr>`attribute:`​<wbr>`relatedBy:`​<wbr>`toItem:`​<wbr>`attribute:`​<wbr>`multiplier:`<wbr>`constant:`​.
With Cartography, they are concise and readable:

```swift
layout(imageView) { imageView in
    imageView.width == 2 * imageView.height
}
```

I also managed to create new attributes to constraint multiple attributes at
once:

```swift
layout(view) { view in
    view.size   <= view.superview!.size / 2
    view.center == view.superview!.center
}
```

As usual, you can find [Cartography on GitHub][cartography].

[swift]: https://developer.apple.com/swift/
[cartography]: https://github.com/robb/Cartography
[flkautolayout]: https://github.com/floriankugler/FLKAutoLayout

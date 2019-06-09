---
color: CC2299
date: 2015-02-06T00:00:00Z
title: Beyond UXKit
category: thinking-about
slug: beyond-uxkit
---

Yesterday, Apple seeded the beta version of 10.10.3 to developers. It contained
the long-awaited Photos app, an overdue successor to iPhoto. It also
contained, however, a much more unexpected surprise. When poking around the
app's internals, [Jonathan Willing][willing] came across a new internal
framework, he wrote:

> The new Photos for Mac is based on a new private framework in 10.10.3, UXKit.
> It is essentially a replica of UIKit, based on top of AppKit.

> It includes favorites such as UXView, UXNavigationController, UXControl,
> UXCollectionView, UXTableView, UXLabel, UXImageView, and much more.

Since UIKit was built with years of experience of AppKit being in production,
many consider its APIs superior to AppKit's. Bringing those interfaces over to
OS X would make it easier to switch between the two platforms and even allow for
cross platform code where the interaction patterns permit it.

This got a lot of people pretty excited.

Now, we don't know if UXKit is more than just a convenient shim built by the
Photos team and if it will ever become a public framework, but even if it will, 
_it won't be enough_.

UXKit is not a leap forwards, it is at best a _sidewards_ step over the platform
gap. The whole paradigm of stateful UI components being whipped into shape on
the main thread is broken beyond repair.

```objc
- (void)userDidLogIn:(NSNotification *)notification {
    [self updateAllTheViews]; // You better be on the main thread.
}
```

It's 2015 and you can't even layout an off-screen view when you're not on the
main thread. We _need_ something better.

### React and beyond 

Facebook recently [announced React Native][keynote], the iOS and Android
extension to their existing React JavaScript framework for building data-driven
UIs in the browser. A lot of people reacted (ha) like this:

> Ewww, JavaScript.
>
> – Too many people

I'm floored that the same community that complains that [40-year][ml] old
language features like generics needlessly complicate their precious
Objective-[Blub] would get their collective nose all up in the air about
JavaScript this way.  
As [Josh Abernathy put it][josh], _JavaScript is an implementation detail._

A couple years back, the same smugness of platform superiority hung around when
Facebook ditched their HTML5 based app (rightfully) for a native implementation.
Little did we know that there would be a lot to learn from the DOM-slingers.

See, I don't know or care if React Native will be what we all write our apps in
two years down the road, but this is not about HTML, it's not about CSS and it
sure as hell ain't about JavaScript.

It's about expressing your application's user interface as a function of this
signature:

```swift
public func updateUI(state: State) -> RootView
```

A pure function like that doesn't need to care what thread it layouts your
views on. Imagine being able to layout all your table-view cells in parallel.
(Facebook's [AsyncDisplayKit] demonstrates some of the performance gains that
can be made by offloading UI calculations to the background.)

An inert representation of your entire view hierarchy is also much easier to
persist than an a tree of `UIView`s. When was the last time you implemented
`-[UXView initWithCoder:]`? Imagine iOS simply restoring the last view hierarchy
on app  start.

Similarly, such a serialization format could be written directly. I'm not the
world's biggest fan of JavaScript, but I'd prefer merging a [JSX] file over a
nib file any day of the week.

If it is completely encapsulated, [hot-swapping] your layout code suddenly
becomes feasible. Every modern browser ships developer tools that beat Interface
Inspector and Reveal single-handedly. Imagine being able to attach Interface
Builder to your running app, [restructuring it on the fly while all data is
being preserved][hot-loader].

And that's only the beginning. Even [impressive touch interactions][slalom] can
be described in only a few lines of declarative constraints.

### Only Apple can do this

There's been a lot of talk in the previous months about the perceived decline in
Apple's software quality. While I don't doubt that a lot of excellent work is
being done inside Apple, from the outside it's still a <s>black</s> space-gray
box.  
I just hope that somewhere inside that box, a true successor to UIKit is being
built, something that will take us to the iPhone 12S and beyond.

We can't reap the full benefits of Swift's powerful language features if we're
being constrained by `UIViewController` in its current form. We won't easily
maintain a smooth 60 fps if even basic layouting is shackled to the main thread.
We need to pop our filter bubbles and steal the best ideas from Android, the Web
and [1973].

I'm no longer fully sure that the future of iOS UI engineering will come out of
Cupertino, but I'd love to be proven wrong in June.

#### Related links

- [Josh Abernathy – Why React Native Matters][josh]
- [Andy Matuschak – Functioning as a Functionalist](https://www.youtube.com/watch?v=rJosPrqBqrA)

[1973]:            https://vimeo.com/71278954
[asyncdisplaykit]: http://asyncdisplaykit.org/
[blub]:            http://www.paulgraham.com/avg.html
[hot-loader]:      https://gaearon.github.io/react-hot-loader/
[hot-swapping]:    https://www.youtube.com/watch?v=7rDsRXj9-cU#t=1376
[josh]:            https://joshaber.github.io/2015/01/30/why-react-native-matters/
[jsx]:             https://facebook.github.io/jsx/
[keynote]:         https://code.facebook.com/videos/786462671439502/react-js-conf-2015-keynote-introducing-react-native-/
[ml]:              https://en.wikipedia.org/wiki/ML_%28programming_language%29
[slalom]:          https://iamralpht.github.io/constraints/
[willing]:         https://twitter.com/willing

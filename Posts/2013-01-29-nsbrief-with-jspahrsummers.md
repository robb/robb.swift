---
color: DD3355
date: 2013-01-29T00:00:00Z
link: http://nsbrief.com/81-justin-spahr-summers/
title: NSBrief with Justin Spahr-Summers
category: ❤ing
slug: nsbrief-with-jspahrsummers
---

GitHub for Mac developer [Justin Spahr-Summers][jspahrsummers] has been the
featured guest on [the most recent episode of NSBrief][nsbrief] where he talks
about _libextobj_, _Mantle_ and of course _ReactiveCocoa_. If you haven't heard
of these yet, let me give you a quick run-down:

[libextobj] is a library that seeks to extend Objective-C with patterns found in
other programming languages. I think it's great to see someone push the envelope
of what's possible in Objective-C.

Some of the more practical highlights include:

* _Safe categories_, for adding methods to a class without
  overwriting anything.
* _Simpler and safer key paths_ &  _Compile-time checking of selectors_
* _Easier use of weak variables in blocks_
* _Scope-based resource cleanup_, for automatically cleaning up manually-
  allocated memory, file handles, locks, etc..
* _EXTNil_, which is like NSNull, but behaves much more closely to actual nil

[Mantle], a model framework used in GitHub's Mac client, takes away some of the
common boilerplate when dealing with JSON APIs by using convention over
configuration. However, it's not incompatible with Core Data and can easily be
used alongside of it.

Last but not least, [ReactiveCocoa] is a powerful library that brings the
concepts of [Reactive Programming][frp] to the land of rounded corners. By
modeling behavior as values that transform over time, rather than mutable state
held in variables, Reactive Programming can greatly improve the locality of your
code and make it more concise.
For this topic alone, the podcast is worth a listen.

I've been investigating ReactiveCocoa at SoundCloud recently and I think it's a
powerful tool when dealing with asynchronous IO and complex user interactions –
but more on that later.

[jspahrsummers]: https://github.com/jspahrsummers
[nsbrief]: http://nsbrief.com/81-justin-spahr-summers/
[libextobj]: https://github.com/jspahrsummers/libextobjc
[mantle]: https://github.com/github/Mantle
[reactivecocoa]: https://github.com/github/ReactiveCocoa
[frp]: http://en.wikipedia.org/wiki/Functional_reactive_programming

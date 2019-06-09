---
color: 3A579B
date: 2012-08-23T00:00:00Z
link: https://www.facebook.com/notes/facebook-engineering/under-the-hood-rebuilding-facebook-for-ios/10151036091753920
title: Under the Hood – Rebuilding Facebook for iOS
category: ❤ing
slug: rebuilding-facebook-for-ios
---

Facebook finally released a rewrite of their mobile application, eschewing
WebViews in favor of a fully native experience.

[Former SOFA developer][sofa] Jonathan Dann writes:

> The development of this new app signals a shift in how Facebook is building
> mobile products, with a focus on digging deep into individual platforms. To
> understand how we approached this shift, let's take a look at how Facebook has
> evolved on mobile.

There are some interesting tidbits in there:

> To give another example, we use Core Text to lay out many of our strings, but
> layout calculations can quickly become a bottleneck. With our new iOS app, […]
> we asynchronously calculate the sizes for all these strings, cache our
> CTFramesetters […] and then use all these calculations later when we present
> the story into our UITableView.

Not having to layout strings yourself is probably the reason why a lot of
otherwise native applications use WebViews. They use a similar approach with
table view cells, too:

> Firstly, when we do our initial asynchronous layout calculations, we also
> store the height of the story in Core Data. In doing so, we completely avoid
> layout calculation in -tableView:heightForRowAtIndexPath:. Secondly, we've
> split up our "story" model object. We only fetch the story heights […] from
> disk on startup. Later, we fetch the rest of the story data, and any more
> layout calculations we have to do are all performed asynchronously.

If you care about performance on iOS, make sure to take a lot [at the
article][post].

[sofa]: http://techcrunch.com/2011/06/09/facebook-sofa/
[post]: https://www.facebook.com/notes/facebook-engineering/under-the-hood-rebuilding-facebook-for-ios/10151036091753920

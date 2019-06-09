---
color: 6688CC
date: 2013-01-27T00:00:00Z
link: https://github.com/ksuther/KSImageNamed-Xcode
title: KSImageNamed Xcode plug-in
category: ❤ing
slug: ksimagenamed
---

A common pain-point when dealing with user interfaces in Xcode is making sure
you correctly call `-[UIImage imageNamed:]`. Since the compiler does not assist
you with making sure the the image name you pass in actually exists, it's easy
for typos to sneak in.

Enter [KSImageNamed], a nifty Xcode plugin that adds auto-completion for exactly
this case:

<div class="image">
	<img src="/img/ksimagenamed.png" alt="KSImageNamed in action">
</div>

> Just type in [NSImage imageNamed: or [UIImage imageNamed: and all the images
> in your project will conveniently appear in the autocomplete menu.

Easy as that! Makes me wish Xcode could to this out of the box.

[ksimagenamed]: https://github.com/ksuther/KSImageNamed-Xcode

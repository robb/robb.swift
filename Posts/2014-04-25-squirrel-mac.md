---
color: 80A0E0
date: 2014-04-25T00:00:00Z
link: https://github.com/Squirrel/Squirrel.Mac
title: Squirrel.Mac
category: ❤ing
slug: squirrel-mac
---

<div class="image">
    <a href="http://https://github.com/Squirrel/Squirrel.Mac">
        <img src="/img/squirrel.png" alt="The Squirrel squirrel">
    </a>
</div>

GitHub just open-sourced the Mac version of their updating framework [Squirrel].

Unlike the ubiquitous [Sparkle], Squirrel requires some server-side logic to determine which update should be installed. This makes clients simpler and should allow for easier roll-backs as well as staged roll-outs.

Updates are applied automatically, as soon as the app terminates. This helps making sure that clients are always up-to-date, an approach I guess we've come to love from Chrome.

Note that it also doesn't come with a UI, so you can't rely on the familiar Sparkle changelog view and would have to roll your own.

[squirrel]: https://github.com/Squirrel/Squirrel.Mac
[sparkle]:  http://sparkle.andymatuschak.org/

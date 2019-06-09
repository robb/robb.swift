---
date: 2011-07-09T00:00:00Z
description: Add oEmbed to your static website
title: An embed.ly plug-in for Jekyll
category: working-on
slug: embedly-and-jekyll
---

### This plug-in is no longer supported, sorry!

I use the static webpage generator [Jekyll][jekyll] for running this site and
I absolutely love it.
Combined with Github’s powerful [github-pages][gh-pages] feature, I get a well
performing site with minimal effort and a convenient git-based workflow.

As you can see, I post a lot of SoundCloud tracks and videos on this site, but
I find the process of composing embed links very dull and time-consuming.

To facilitate this process, I wrote [a small Jekyll plug-in][plug-in] that
acts as an [oEmbed][oembed] client using the [embed.ly][embedly] API.

Once you’ve install the plug-in, it will automatically turn every embedly tag
into a nice looking embed every time you compile your site.
If you encounter any problems, make sure
to file a report in the [Issues tracker][issues].

Now, do you care for an example?

## Wikipedia

<pre><code>{<!---->% embedly http://en.wikipedia.org/wiki/SoundCloud %}</code></pre>

## XKCD

<pre><code>{<!---->% embedly http://xkcd.com/918 %}</code></pre>

## Flickr

<pre><code>{<!---->% embedly http://www.flickr.com/photos/visivo/3389278626 %}</code></pre>

Overall, embed.ly supports over 180 services. I’ve made sure you can customize
and style your embeds as well as possible.

## However…

Unfortunately, [github-pages][gh-pages] does not offer support for plug-ins
for security reasons. To make use of this (and any other Jekyll plug-in), you
have to compile your site yourself and push it to your pages repo manually.

Maybe they could include a plug-in like this in the future?

[jekyll]:   https://github.com/mojombo/jekyll
[oembed]:   http://oembed.com
[embedly]:  http://embed.ly
[plug-in]:  https://github.com/robb/jekyll-embedly-client
[gh-pages]: http://pages.github.com
[issues]:   https://github.com/robb/jekyll-embedly-client/issues

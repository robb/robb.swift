---
color: E2802E
date: 2012-08-30T00:00:00Z
link: http://corner.squareup.com/2012/08/ponydebugger-remote-debugging.html
title: PonyDebugger – Remote Debugging for iOS
category: ❤ing
slug: ponydebugger
---

<img src="/img/ponydebugger.png" class="float right">
[PonyDebugger][ponydebugger] is a powerful new tool released by the Square iOS
team today. It consists of a client library and server component to remotely
debug the network traffic and Core Data stack of your application

> PonyDebugger acts as a powerful network debugger, allowing users the ability
> to see an application’s network requests in real time. This means that it
> reports not only all request and response headers, but how long each request
> takes, associated cookies and the data itself if it is human-readable.

What's especially nice is, that PonyDebugger is built on top of the WebKit Web
Inspector. Web developers will feel _right at home_ and it's a testament to the
great work done by the WebKit team.

If your app communicates with one API or another, you're _of course_ using SSL
to shield your user's data against prying eyes. However, debugging an
application that uses encrypted communication can sometimes be a hassle –
encryption has to be turned off for debug builds or a specific, trusted
certificate has to be installed. With PonyDebugger, there is now an alternative:

> PonyDebugger forwards network traffic without sniffing it. This means that
> traffic sent over a secure protocol (https) is reported.

I've been using [Charles Proxy][charles] for this and while I like it, I'm
looking forward to having something more tightly integrated with the iOS
platform.

_But there's more,_ PonyDebugger can also be used to inspect your Core Data
store. This makes browsing your data a breeze and should considerably speed up
your Core Data debugging.

[ponydebugger]: http://corner.squareup.com/2012/08/ponydebugger-remote-debugging.html
[charles]:      http://www.charlesproxy.com/
[soundcloud]:   http://itunes.apple.com/en/app/soundcloud/id336353151

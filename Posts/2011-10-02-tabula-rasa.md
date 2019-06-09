---
color: 71629A
archived: true
date: 2011-10-02T00:00:00Z
title: Tabula Rasa
category: thinking-about
slug: tabula-rasa
---

Today I finally received my new 13 inch MacBook Air. I've been pondering over
this for a while, going back and forth between this, or a MacBook Pro. I
ultimately chose portability over processing power and went with the Air, let's
see how this pans out over the next couple of months.

In many ways, getting a new machine is like sleeping in a freshly made bed,
everything feels nice and clean and there are no crumbs hidden under the cover,
yet. It also presents you with a nice opportunity to reevaluate your working
environment.

Inspired by reading about other peoples setup on
[usesthis][usesthis.com] (see for example one by [Richard Stallman][rms]), I
figured I might as well write something about some of my favorite applications.
So, without much further ado, here is a list of my tools of the trade and
whatever else I use on a daily basis:

## F.lux

<img src='/img/flux.png' alt='F.lux' class='right' />
F.lux is a small application that controls the white balance of your
computer's monitor. Computer screens usually have a white-point of
[6500° Kelvin][d65] – while that looks great in broad daylight, in the evening
that usually means that you're staring at a bright, blueish rectangle while
everything else is covered in warm, yellow light. This is unnecessarily tiring
your eyes.

F.lux fixes this by dynamically setting the white point of your monitor to
something cooler after sunset, which makes your screen's colors appear warmer.

_Even if you don't run Mac OS X_ on your computer, go and
[install this program][flux] right now! It's available for Windows and Linux,
too. How comes you can read this if you're installing F.lux? Do you got it? OK,
let's continue…

## iTerm 2

iTerm 2 is a great replacement for the default Terminal.app OS X
ships with. It has a couple of great features such as split windows, Growl
support and is much more customizable than the default.

<div class="image">
    <img src='/img/iterm-2.png' alt='iTerm 2' />
</div>

The main reason I use it, however, is its awesome _Hotkey Window_. Define a
global hotkey and get access to a terminal window wherever you are. I set my
Caps Lock key to open a fullscreen terminal window by mapping the key to F13
using the awkwardly named [PCKeyboardhack][pckeyboardhack] and then assigning
F13 to open the Hotkey Window.

I also removed the fade in animation by running

    $ defaults write com.googlecode.iterm2 HotkeyTermAnimationDuration -float 0

to make the terminal appear instantly.

## Sublime Text 2

Electric Boogaloo. The go-to GUI text editor for developers on OS X has long
been TextMate. While the developer of TextMate has just reiterated that TextMate
2 is alive and well, many have turned to Sublime Text 2 for a modern editor.
It comes with many great features out of the box and is also compatible to some
of TextMates syntax highlighting bundles.

<div class="image">
  <img src='/img/sublime-text-2.png' alt='Sublime Text 2' />
</div>

I switched to [Sublime Text 2][sublimetext2] for most of my personal editing
needs because of its great split screen support and the distraction free mode
in which I am currently writing this blog post while waiting on my plane.

Once I've grown more familiar with all the bells and whistles, I'll probably
make another post how I set it up, as most of the options you can set are
currently not easily discoverable.

## Sparrow

I never got the hang of using web based e-mail clients on a daily
base and about a year ago, I made the switch from Thunderbird to Sparrow.
It has a nice, clean UI and is well integrated with GMail.

There is [a lite version][sparrow_lite] on the Mac App Store, so make sure to
give it a spin.

<div class="image">
  <img src='/img/Sparrow.png' alt='Sparrow' />
</div>

## zsh

The benefits of zsh over bash have been discussed at great length
multiple times now. zsh comes already installed on OS X and you can make it your
default shell by running `chsh -s zsh`.
I'd like to recommend you a little something called [Oh my zsh][oh_my_zsh],
a repo of zsh plugins and themes.<br />
Almost 3000 watchers on github can hardly be wrong…

                   __                                     __
            ____  / /_     ____ ___  __  __   ____  _____/ /_
           / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
          / /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
          \____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
                                  /____/

## What else

If I write something, I probably check it into git at some point.
I'm not a big fan of git GUIs, so I usually stick to the cli version.<br />
For my Objective-C needs, I use a Xcode 4 and not much else.<br />
My current browser of choice is Chrome.<br />

[rms]:            http://richard.stallman.usesthis.com/
[usesthis.com]:   http://usesthis.com/
[flux]:           http://stereopsis.com/flux/
[d65]:            http://en.wikipedia.org/wiki/CIE_Standard_Illuminant_D65
[pckeyboardhack]: http://pqrs.org/macosx/keyremap4macbook/extra.html#t1
[sublimetext2]:   http://www.sublimetext.com/2
[sparrow_lite]:   http://itunes.apple.com/de/app/sparrow-lite/id417418059?mt=12
[oh_my_zsh]:      https://github.com/robbyrussell/oh-my-zsh

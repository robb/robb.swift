---
color: 00CC00
date: 2009-09-20T00:00:00Z
description: A monome-controlled, xylophone-playing robot
project: true
title: Xylobot
category: working-on
slug: the-xylobot
---

I met Ramsey Arnaoot at the Music Hackday Berlin 2009, discussing how underrepresented hardware hacks were, we decided to do something about it and came up with the Xylobot.

The build is nothing special and quite self-explanatory, little hammers made of hot-glued bolts strike the Glockenspiel. The Arduino library suffered from a bug that would let us use only 6 servos, so we had to settle for the major pentatonic scale.

On the computer side, a Java application is listening to incoming MIDI data and triggers the servos using simple serial messages. This was the second project I did with the Arduino and I am still amazed how easily things can be prototyped with this platform. Ramsey wrote a custom Pd-Patch for RjDj to generate music from sensory data, though we haven’t got a video of this.

The Xylobot also was mentioned by Peter in [his Music Hackday wrap-up][cdm_mhd_berlin] on Create Digital Music.

<div class="embed video vimeo">
    <style type="text/css" scoped>
        .embed:after {
            padding-top: 75% !important;
        }
    </style>

    <iframe src="//player.vimeo.com/video/6668819?color=00cc00" width="640" height="480" frameborder="0" title="xylobot run by monome" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
</div>

[cdm_mhd_berlin]: http://createdigitalmusic.com/2009/09/wild-musical-inventions-from-berlin-hackday/

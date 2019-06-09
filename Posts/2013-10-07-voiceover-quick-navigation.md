---
color: 11AA55
date: 2013-10-07T00:00:00Z
title: VoiceOver Quick Navigation
category: thinking-about
slug: voiceover-quick-navigation
---

I've maintained for a long time that great apps should have great accessibility
support, but today I learned of another reason that might also be of particular interest to developers.

If you don't know, _VoiceOver_ is the name of Apple's accessibility technology
to help users with visual or motor impairments use their iPhones. It's most
well-known for its screen reader capabilities, but it also supports controlling
your iPhone or iPad entirely with the keyboard.

This is great to avoid reaching over to your phone all the time, and it's also
much easier to enter your test account's password on a physical keyboard.

### Setup

First, connect a Bluetooth Keyboard to your phone. I use the amazing
[1Keyboard](http://www.eyalw.com/1keyboard/) to share my computer's keyboard
with my iPhone with the touch of a button.

Next, enable VoiceOver. On iOS 7, you'll find it under the _Accessibility_ entry
under _General_ in your Settings app. I also recommend adding VoiceOver to the
_Accessibility Shortcut_ menu for convenient access to by triple-clicking the
Home Button<sup>1</sup>.

### Navigation

VoiceOver allows you navigate through the visible
items both by dragging your finger across the screen and by swiping left and
right over the screen.

Only that, instead of swiping, you can now use your keyboards arrow keys.

Make sure to have _Quick Nav_ enabled by pressing ← → (The left and right arrow
keys) in quick succession. While Quick Nav is enabled, you can iterate over all
accessibility items on the screen using ← and →. Quick Nav makes using VoiceOver
with a keyboard much easier and the rest of the article assumes you have it
running.

Press any of ⌥↑, ⌥↓, ⌥←, or  ⌥→ to scroll the currently active scroll view.

Use ⎋ (Escape) to leave the current screen, that is, to quickly select and tap
the back button.

### Interaction

To interact with a selected element, press ↑ and ↓ in quick succession. When
you're not using the keyboard, you can double-tap anywhere on the screen for the
same effect.

Adjusting sliders, page controls or steppers however requires a different key
command.

Navigate to the element you want to interact with and select _Adjust Value_ in
the _Rotor_ by pressing ↑ and then one of ← or →.

The Rotor is a secondary menu that allows you to chose what happens if you press
↑ or ↓ or swipe up or down on the screen. Once you set it to _Adjust Value_,
you'll be able to use ↑ or ↓ down to adjust values.

There are a couple of other useful settings for the Rotor, such as _Vertical
Navigation_ that can be enabled in the _Rotor_ menu in the VoiceOver settings.

### Advanced shortcuts

Unfortunately, most of the VoiceOver keyboard commands use the awkward
combination of the Control and Options keys. If someone knows a way to map that
to something easier to reach, such as Caps Lock, please let me know!

To press the Home Button, press ⌃⌥H. If you have good eye-sight or share and
office with co-workers, press ⌃⌥S to mute or unmute VoiceOver.

To quickly change VoiceOver settings, such as Speech Rate or Typing Echo, select
a setting using ⌃⌥⌘← or ⌃⌥⌘→ and change the selecting settings with ⌃⌥⌘↑ or
⌃⌥⌘↓.

For reference, here's a complete list of all the keyboard shortcuts supported by
VoiceOver:

### VoiceOver keyboard commands

<table>
    <tr>
        <td>Turn on VoiceOver help</td>
        <td>⌃⌥K</td>
    </tr>
    <tr>
        <td>Turn off VoiceOver help</td>
        <td>⎋</td>
    </tr>
    <tr>
        <td>Select the next or previous item</td>
        <td>⌃⌥→ or ⌃⌥←</td>
    </tr>
    <tr>
        <td>Double-tap to activate the selected item</td>
        <td>⌃⌥Space</td>
    </tr>
    <tr>
        <td>Press the Home button</td>
        <td>⌃⌥H</td>
    </tr>
    <tr>
        <td>Move to the status bar</td>
        <td>⌃⌥M</td>
    </tr>
    <tr>
        <td>Read from the current position</td>
        <td>⌃⌥A</td>
    </tr>
    <tr>
        <td>Read from the top</td>
        <td>⌃⌥B</td>
    </tr>
    <tr>
        <td>Mute or unmute VoiceOver</td>
        <td>⌃⌥S</td>
    </tr>
    <tr>
        <td>Open Notification Center</td>
        <td>Fn⌃⌥↑</td>
    </tr>
    <tr>
        <td>Open Control Center</td>
        <td>Fn⌃⌥↓</td>
    </tr>
    <tr>
        <td>Open the Item Chooser</td>
        <td>⌃⌥I</td>
    </tr>
    <tr>
        <td>Double-tap with two fingers (usually toggles playback)</td>
        <td>⌃⌥-</td>
    </tr>
    <tr>
        <td>Adjust the rotor</td>
        <td>See Quick Nav</td>
    </tr>
    <tr>
        <td>Swipe up or down</td>
        <td>⌃⌥↑ or ⌃⌥↓</td>
    </tr>
    <tr>
        <td>Adjust the speech rotor</td>
        <td>⌃⌥⌘← or ⌃⌥⌘→</td>
    </tr>
    <tr>
        <td>Adjust the setting specified by the speech rotor</td>
        <td>⌃⌥⌘↑ or ⌃⌥⌘↓</td>
    </tr>
    <tr>
        <td>Turn the screen curtain on or off</td>
        <td>⌃⌥⇧S</td>
    </tr>
    <tr>
        <td>Return to the previous screen</td>
        <td>⎋</td>
    </tr>
</table>

### Quick Nav keyboard commands

Turn on Quick Nav to control VoiceOver using the arrow keys.

<table>
    <tr>
        <td>Turn Quick Nav on or off</td>
        <td>← →</td>
    </tr>
    <tr>
        <td>Select the next or previous item</td>
        <td>→ or ←</td>
    </tr>
    <tr>
        <td>Select the next or previous item specified by the rotor</td>
        <td>↑ or ↓</td>
    </tr>
    <tr>
        <td>Select the first or last item</td>
        <td>⌃↑ or ⌃↓</td>
    </tr>
    <tr>
        <td>Double-tap to activate the selected item</td>
        <td>↑ ↓</td>
    </tr>
    <tr>
        <td>Scroll up, down, left, or right</td>
        <td>⌥↑, ⌥↓, ⌥←, or  ⌥→</td>
    </tr>
    <tr>
        <td>Adjust the rotor</td>
        <td>↑ ← or ↑ →</td>
    </tr>
</table>

I hope that this neat trick helps you avoid some arm strain from repeatedly reaching over
to your phones. If you'd like to read more about accessibility, check out
sessions [200 & 202 from this year's WWDC](https://developer.apple.com/wwdc/videos/).

<ol class="footnotes">
    <li>
        You may also want to enable <i>Invert Colors</i> for reading in bed,
        while you're at it.
    </li>
</ol>

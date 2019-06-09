---
color: CCBBAA
date: 2012-07-02T00:00:00Z
description: An Objective-C library for manipulating data structures.
project: true
title: Underscore.m
category: working-on
slug: underscore.m
---

A couple of weeks ago, I started working on [Underscore.m][underscorem]. It's a
small utility library that helps you with manipulating data structures in
Objective-C.

Here's a quick example:

```objc
// An array of tweets we obtained by deserializing the
// JSON data from the twitter API
NSArray *processed = _array(tweets)
    // Let's make sure that we only operate on NSDictionaries,
    // you never know with these APIs ;-)
    .filter(Underscore.isDictionary)
    // Remove all tweets that are in English
    .reject(^BOOL (NSDictionary *tweet) {
        return [[tweet valueForKey:@"iso_language_code"] isEqualToString:@"en"];
    })
    // Create a simple string representation for every tweet
    .map(^NSString *(NSDictionary *tweet) {
        NSString *name = [tweet valueForKey:@"from_user_name"];
        NSString *text = [tweet valueForKey:@"text"];

        return [NSString stringWithFormat:@"%@: %@", name, text];
    })
    .unwrap;
```

If you know Objective-C, you can probably tell that it uses a somewhat
unconventional syntax. Underscore.m eschews square brackets as they are not well
suited for chaining. [[[[[[[[[They will pile up at the beginning of your call
chain and add unnecessary noise.

Don't get me wrong, I think named arguments in Objective-C are great. They make
code a lot more self-descriptive. Consider

```objc
[[RBMelon alloc] initWithNumberOfSeeds:0
                     andPriceInDollars:1.50];
```

compared to, let's say its Java equivalent

```java
new Melon(0, 1.50);
```

The latter makes it much harder to guess what those two parameters mean. Now,
Java's popular IDEs make it easy to look up the documentation or definition of
methods, but it's still an unnecessary overhead.

However, the Java example is still a lot shorter, so named arguments are clearly
a double edged sword.

If you've written at least a tiny bit of Objective-C, you've probably come in
contact with

```objc
[NSDictionary dictionaryWithObjectsAndKeys:@"foo", [NSNumber numberWithInt:1],
                                           @"bar", [NSNumber numberWithInt:2],
                                           @"baz", [NSNumber numberWithInt:3],
                                           nil];
```

which, thankfully, Objective-C now has a literal for:

```objc
@{ @1: @"foo", @2: @"bar", @3: @"baz" }
```

Similarly, the usual functional suspects like `map`, `reduce`, `tail` etc., are
well understood and don't need a verbose, 20 character selector associated with
them.

This is were Underscore.m comes in. By providing a tool-set of the most common
functional idioms, it tries to encourage developers to structure their
operations in small, concise chucks.

Similar to Objective-C's new literals, I hope its clarity can outweigh conventions.

[underscorem]: https://robb.github.io/Underscore.m/

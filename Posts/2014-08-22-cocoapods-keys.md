---
color: C04546
date: 2014-08-22T00:00:00Z
link: https://github.com/orta/cocoapods-keys
title: CocoaPods Keys
category: ❤ing
slug: cocoapods-keys
---

[Orta] released [a clever new CocoaPods plug-in][cocoapods-keys] to manage keys,
application secrets and the like. Pretty much everything you don't want to check
into your repository.

After you install the plug-in, storing the keys in the OS X Keychain and
accessing them in your code becomes dead simple:

> You can save keys on a per-project basis by running the command:

```bash
$ pod keys set KEY VALUE
```

> After the next pod install or pod update keys will add a new Objective-C class
> to your Pods xcworkspace.

```objc
#import "ORAppDelegate.h"
#import <CocoaPods-Keys/MyApplicationKeys.h>
#import <ARAnalytics/ARAnalytics.h>

@implementation ORAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    MyApplicationKeys *keys = [[MyApplicationKeys alloc] init];
    [ARAnalytics setupWithAnalytics:@{
        ARGoogleAnalyticsID : keys.analyticsToken;
    }];
}

@end
```

I think this is a great example of what can be built on top of the CocoaPods
infrastructure. That being said, I assume that someone will write a similar but
independent script soon.

Note that it depends on the upcoming CocoaPods 0.34.

[orta]: https://twitter.com/orta
[cocoapods-keys]: https://github.com/orta/cocoapods-keys

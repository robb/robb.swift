---
color: 88AACC
date: 2013-02-09T00:00:00Z
description: Easy stubbing for Objective-C.
project: true
title: Stubbilino
category: working-on
slug: stubbilino
---

[Stubbilino] is a small library I wrote to help with stubbing in Objective-C. I
was looking for a block-based interface for stubbing to use together with
Specta.

```objc
afterEach(^{
  [Stubbilino removeAllStubs];
});

describe(@"A user view controller", ^{
  __block XYUserViewController *viewController;

  beforeEach(^{
    viewController = [[XYUserViewController alloc] init];
  });

  it(@"should display the username", ^{
    id<SBStub> stub = [Stubbilino stubObject:viewController];

    [stub stubMethod:@selector(user) withBlock:^{
      return kXYTestUser;
    }];

    [viewController.view reloadData];

    expect(viewController.view.usernameLabel.text)
      .to.equal(kXYTestUser.username);
  });
});
```

You can also stub class methods, for instance, here is how to swap the default
NSNotificationCenter for a custom instance.

```objc
Class<SBClassStub> stub = [Stubbilino stubClass:NSNotificationCenter.class];

[stub stubMethod:@selector(defaultCenter) withBlock:^{
  return myNotificationCenter;
}];
```

If you would like to give Stubbilino a try, you can [find the code on
GitHub][stubbilino].

[stubbilino]: https://github.com/robb/Stubbilino

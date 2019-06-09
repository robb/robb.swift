---
color: EE5050
date: 2013-01-31T00:00:00Z
link: http://www.jumsoft.com/2013/01/response-to-sync-issues/
title: Jumsoft pulling iCloud sync from Money
category: ❤ing
slug: jumsoft-pulling-icloud-sync
---

[Jumsoft], the creators of the popular expense-tracker app Money, pulled iCloud
sync in the latest versions of their app.

> All of you surely know many document-based apps that use iCloud and seem to be
> doing absolutely fine. That’s why it must seem odd that Jumsoft is utterly
> incapable of developing a proper iCloud sync feature. However, the big
> difference between Money and those iCloud-friendly apps is that Money uses a
> relational database created with Core Data to handle its highly complex data
> models.

Apparently, Jumsoft had to make a call here: iCloud or Core Data.

Since Core Data tends to be an all-in kind of investment, it is likely that most
of their domain objects are generated from the Managed Object Model. Pulling out
Core Data would then prove prohibitively expensive.

[jumsoft]: http://www.jumsoft.com

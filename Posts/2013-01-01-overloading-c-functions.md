---
color: 90B012
date: 2013-01-01T00:00:00Z
title: Overloading C Functions with Clang
category: thinking-about
slug: overloading-c-functions
---

Clang, LLVM's compiler front-end for C-based languages, features a couple of
[interesting language extensions][extensions] to C, C++ and Objective-C. You are
probably familiar with auto-synthesis of properties or the new subscripting
syntax.

One of the lesser known extensions, however, is the `__attribute__((overloadable))` annotation.

While languages like Java and C++ allow you to define multiple functions with
the same name but different arguments, this feature has been absent from C.

However, using recent versions of Clang you can now rectify this behavior and
since Objective-C is a superset of C, knowing how to use this feature can be
useful even if you rarely venture outside of Cocoa or Cocoa Touch.

Consider for example these function declarations:

```objc
#define OVERLOADABLE __attribute__((overloadable))

OVERLOADABLE NSArray *map(NSArray *array, id(^)(id obj));
OVERLOADABLE NSDictionary *map(NSDictionary *dictionary, id(^)(id key, id obj));
```

We declare two different versions of the classic `map` function.  
Instances of NSArray will have a block applied to their elements that takes a
single argument while instances of NSDictionary have both their keys and values
sent to the block.

The compiler will figure out which `map` it needs to call simply based on the
types of the arguments.

The implementation is pretty straightforward, too:  
`-[NSArray enumerateObjectsUsingBlock:]` is used to iterate over all elements.
If the block passed to `map` returns `nil`, the element is discarded. 

```objc
OVERLOADABLE NSArray *map(NSArray *array, id(^block)(id))
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];

    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id mapped = block(array);

        if (mapped) [result addObject:mapped];
    }];

    return result;
}
```

You may want to consider writing a parallel version of `map` that makes use of 
`-[NSArray enumerateObjectsWithOptions:usingBlock:]` and passes in
`NSEnumerationConcurrent`.

The implementation for dictionaries looks similar:

```objc
OVERLOADABLE NSDictionary *map(NSDictionary *dict, id(^block)(id, id))
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:dict.count];

    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id mapped = block(key, obj);

        if (mapped) result[key] = mapped;
    }];

    return result;
}
```

Now we have a nice and clean way to map over Cocoa's most prevalent data
structures:

```objc
NSArray *numbers = @[ @1, @2, @3, @4 ];

NSArray *doubled = map(numbers, ^NSNumber *(NSNumber *number) {
    return @(2 * number.doubleValue);
});

NSDictionary *user = @{
  @"username": @"robb",
  @"website": @"http://robb.is"
};

// Implementing 'each' and its concurrent equivalent
// is left as an exercise to the reader.
each(user, ^(NSString *key, id obj) {
    NSLog(@"%@: %@", key, obj);
});
```

I think function overloading is a welcome addition to C and it goes to show how
knowing the underpinnings of Objective-C can help you write better and more
concise code.

_Update:_ [Nick Lockwood][nicklockwood] raised the point that `map` may be
better suited for a category. When I came up with this example, I was also
considering an `each` implementation that could deal with
`id<NSFastEnumeration>`. E.g.:

```objc
OVERLOADABLE void each(id<NSFastEnumeration> list, void(^)(id obj));
OVERLOADABLE void each(NSArray *array, void(^)(id obj));
OVERLOADABLE void each(NSDictionary *dict, void(^)(id key, id obj));
```

That being said, if you're looking for a solid and well tested map category,
check out [BlocksKit].

[extensions]:   http://clang.llvm.org/docs/LanguageExtensions.html
[nicklockwood]: https://twitter.com/nicklockwood
[blockskit]:    https://github.com/pandamonia/BlocksKit

# TimeKeeper

This package has a utility class called `TimeKeeper`, which is a convenience class to keep track of the current time and date. Behind the scenes, it uses a `Timer` to get the updated `Date`, using the current system `Calendar` to extract time/date components. At the specified time interval, the time will be updated. A `TimeKeeper` instance can be started with it's own built-in `Timer` or without to relay on an external `Timer`.

This package also has a class called `TimeEmitter`, which can be used with projects using SwiftUI and/or the Combine framework. `TimeEmitter` is an `ObservableObject` with a published `TimeKeeper`.

## Basic Usage

If you already have a `Timer` you want to use, you can simply start your `TimeKeeper` without parameters. Just tell your timer to call the `TimeKeeper`'s `update()` method whenever your `Timer` fires.

```swift
let timeKeeper = TimeKeeper()
```
If you want the `TimeKeeper` to manage it's own `Timer`, just give it a `TimeInterval`:

```swift
let timeKeeper = TimeKeeper(updatedEvery: 1.0)
```
Whenever you need a date component, just call one of the `TimeKeeper`'s methods:

```swift
let minute = timeKeeper.minute
let second = timeKeeper.second
```
Keep in mind that most methods will return an optional value.

## TimeEmitter

If your project is using SwiftUI and/or the Combine framework, `TimeEmitter` is a useful wrapper for `TimeKeeper`:

```swift
let timeEmitter = TimeEmitter(updatedEvery: 1.0)
```
`TimeEmitter` is an `ObservableObject` which creates a published `TimeKeeper`, which can be accessed with the `time` property:

```swift
let minute = timeEmitter.time.minute
let second = timeEmitter.time.second
```

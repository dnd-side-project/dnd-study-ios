# Observable

[Examples](./RxSwiftPlayground.playground/Contents.swift)

## What is an observable?

The core of Rx.

Observable, Observable Sequence, Sequence are all the same thing.

In a nutshell, an `Observable` is just a sequence, which is **asynchronous**.

Observables produce events with values over a period of time: **emitting**.

![Observable1](./res/observable1.png)

- Emits values till the end of the lifecycle of an observable.

## Lifecycle of an observable

1. Emits next events with elements.

2. Continue till the event terminated.

   - e.g. error / completed

3. Can no longer emit events.

## Creating observables

- `Observable<T>.just`: Just a single element

- `Observable.of(T)`: Multiple elemtns<T> respectively

- `Observable.of([T])`: A single array element

- `Observable.from([T])`: Individual elements from an array sequentially

## Subscribing to observables

Use `subscribe()` instead of `addObserver()` for `NotificationCenter`

Each observable is different unlike `NotificationCenter.default` singleton instance.

Event such as `next`, `completed` has an element property, which is an optional value.(`.subscribe(:)`)

To get an element without event, `.subscribe(onNext:)`

## Disposing and terminating

- `dispose()` on a subscription cancels the subscription.

- `disposed(by: DisposeBag)`: will prevent memoery leaked.

import UIKit
import Foundation
import RxSwift
import RxCocoa

enum MyError: Error {
  case anError
}

//example(of: "just, of, from") {
//    // 1
//    let one = 1
//    let two = 2
//    let three = 3
//
//    // 2
//    let observable = Observable<Int>.just(one)
//    let observable2 = Observable.of(one, two, three)
//    let observable3 = Observable.of([one, two, three])
//    let observable4 = Observable.from([one, two, three])
//}

//example(of: "subscribe") {
//    let one = 1
//    let two = 2
//    let three = 3
//
//    let observable = Observable.of(one, two, three)
//
//    observable.subscribe { event in
//        print(event)
//    }
//
//    observable.subscribe { event in
//        if let element = event.element {
//            print(element)
//        }
//    }
//
//    observable.subscribe(onNext: { element in
//        print(element)
//    })
//}

//example(of: "empty") {
//
//    // An observable must be defined as a specific type if it cannot be inferred
//    let observable = Observable<Void>.empty()
//
//    observable.subscribe(
//      // 1
//      onNext: { element in
//        print(element)
//      },
//
//      // 2
//      onCompleted: {
//        print("Completed")
//      }
//    )
//
//}

//example(of: "range") {
//  // 1
//  let observable = Observable<Int>.range(start: 1, count: 10)
//
//  observable
//    .subscribe(onNext: { i in
//      // 2
//      let n = Double(i)
//
//      let fibonacci = Int(
//        ((pow(1.61803, n) - pow(0.61803, n)) /
//          2.23606).rounded()
//      )
//
//      print(fibonacci)
//  })
//}

//example(of: "dispose") {
//  // 1
//  let observable = Observable.of("A", "B", "C")
//
//  // 2
//  let subscription = observable.subscribe { event in
//    // 3
//    print(event)
//  }
//
//    subscription.dispose()
//
//}

//example(of: "DisposeBag") {
//  // 1
//  let disposeBag = DisposeBag()
//
//  // 2
//  Observable.of("A", "B", "C")
//    .subscribe { // 3
//      print($0)
//    }
//    .disposed(by: disposeBag) // 4
//}

//example(of: "create") {
//    let disposeBag = DisposeBag()
//
//    // The create operator takes a single parameter named subscribe
//    Observable<String>.create { observer in
//      // 1
//      observer.onNext("1")
//
////      observer.onError(MyError.anError)
////
////      // 2
////      observer.onCompleted()
//
//      // 3
//      observer.onNext("?")
//
//      // 4
//      // Return a disposable, defining what happens when your observable is terminated or disposed of;
//      // in this case, no cleanup is needed so you return an empty disposable.
//      return Disposables.create()
//    }
//    .subscribe(
//      onNext: { print($0) },
//      onError: { print($0) },
//      onCompleted: { print("Completed") },
//      onDisposed: { print("Disposed") }
//    )
//    .disposed(by: disposeBag)
//}

//example(of: "deferred") {
//  let disposeBag = DisposeBag()
//
//  // 1
//  var flip = false
//
//  // 2
//  let factory: Observable<Int> = Observable.deferred {
//
//    // 3
//    flip.toggle()
//
//    // 4
//      // 새로운 subscriber에겐 새로운 Observable 전달
//    if flip {
//      return Observable.of(1, 2, 3)
//    } else {
//      return Observable.of(4, 5, 6)
//    }
//  }
//
//    for _ in 0...3 {
//      factory.subscribe(onNext: {
//        print($0, terminator: "")
//      })
//      .disposed(by: disposeBag)
//
//      print()
//    }
//}

//example(of: "Single") {
//  // 1
//  let disposeBag = DisposeBag()
//
//  // 2
//  enum FileReadError: Error {
//    case fileNotFound, unreadable, encodingFailed
//  }
//
//  // 3
//  func loadText(from name: String) -> Single<String> {
//    // 4
//    return Single.create { single in
//        // 1
//        let disposable = Disposables.create()
//
//        // 2
//        guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
//          single(.failure(FileReadError.fileNotFound))
//          return disposable
//        }
//
//        // 3
//        guard let data = FileManager.default.contents(atPath: path) else {
//          single(.failure(FileReadError.unreadable))
//          return disposable
//        }
//
//        // 4
//        guard let contents = String(data: data, encoding: .utf8) else {
//          single(.failure(FileReadError.encodingFailed))
//          return disposable
//        }
//
//        // 5
//        single(.success(contents))
//        return disposable
//
//    }
//  }
//    // 1
//    loadText(from: "Copyright")
//    // 2
//      .subscribe {
//        // 3
//        switch $0 {
//        case .success(let string):
//          print(string)
//        case .failure(let error):
//          print(error)
//        }
//      }
//      .disposed(by: disposeBag)
//
//}

// CHALLENGE 1
example(of: "never") {
    let observable = Observable<Void>.never()
    let disposeBag = DisposeBag()
    
    observable
        .do(onSubscribe: {
            print("Do Operator")
        })
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            }
        )
        .disposed(by: disposeBag)
}

// CHALLENGE 2
example(of: "never") {
    let observable = Observable<Void>.never()
    let disposeBag = DisposeBag()
    
    observable
        .debug("Debug")
        .subscribe(
            onNext: { element in
                print(element)
            },
            onCompleted: {
                print("Completed")
            },
            onDisposed: {
                print("Disposed")
            }
        )
        .disposed(by: disposeBag)
}

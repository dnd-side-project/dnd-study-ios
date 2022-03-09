import UIKit
import RxSwift
import RxCocoa

public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

// MARK: - Ignore Elements
example(of: "ignoreElements") {
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    // 2
    strikes
        .ignoreElements()           // complete, error 빼곤 다 무시
        .subscribe { _ in
            print("You're out!")
        }
        .disposed(by: disposeBag)
    
    strikes.onNext("X")             // ignore
    strikes.onNext("X")             // ignore
    strikes.onNext("X")             // ignore
    
    strikes.onCompleted()           // complete
}

// MARK: - Element At
example(of: "elementAt") {
    
    // 1
    let strikes = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    //  2
    strikes
        .element(at: 2)
        .subscribe(onNext: { _ in
            print("You're out!")
        })
        .disposed(by: disposeBag)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X") // 구독자에게 영향을 주는 next event
}

// MARK: - Filter
example(of: "filter") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
    // 2
        .filter { $0.isMultiple(of: 2) }
    // 3
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Skip
example(of: "skip") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
    // 2
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Skip While
example(of: "skipWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 3, 4, 4)
    // 2
        .skip(while: { $0.isMultiple(of: 2) })
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Skip Until
example(of: "skipUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .skip(until: trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    subject.onNext("A")
    subject.onNext("B")
    
    trigger.onNext("X")
    subject.onNext("C")
    
}

// MARK: - Take
example(of: "take") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5, 6)
    // 2
        .take(3)
        .toArray()
        .subscribe(onSuccess: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Take While
example(of: "takeWhile") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2, 2, 4, 4, 6, 6)
        .enumerated()                   // index를 알고 싶을 때 쓰는 조건
        .take(while: { index, integer in
            integer.isMultiple(of: 2) && index < 3
        })
        .map(\.element)                 // tuple에서 element만 추출
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Take Until
example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1, 2, 3, 4, 5)
    // 2
        .take(until: { $0.isMultiple(of: 4) },
              behavior: .inclusive)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

// MARK: - Take Until
example(of: "takeUntil trigger") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .take(until: trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 3
    subject.onNext("1")
    subject.onNext("2")
    
    trigger.onNext("X")
    
    subject.onNext("3")
}

// MARK: - Distinct Operators
example(of: "distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "A", "B", "B", "A")
    // 2
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    // 3
        .distinctUntilChanged { a, b in
            // 4
            guard
                let aWords = formatter
                    .string(from: a)?
                    .components(separatedBy: " "),
                let bWords = formatter
                    .string(from: b)?
                    .components(separatedBy: " ")
            else {
                return false
            }
            
            var containsMatch = false
            
            // 5
            for aWord in aWords where bWords.contains(aWord) {
                containsMatch = true
                break
            }
            
            return containsMatch
        }
    // 6
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "Challenge 1") {
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Shai",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()    // int 배열을 문자열로 만드는 방법
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let input = PublishSubject<Int>()
    
    input
        .skip(while: { $0 == 0 })
        .filter { $0 < 10 }
        .take(10)
        .toArray()
        .subscribe(onSuccess: {
            let phone = phoneNumber(from: $0)
            
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }
        })
        .disposed(by: disposeBag)
    
    input.onNext(0)     // 0이라 스킵됨
    input.onNext(603)   // 10 이상이라 스킵됨
    
    input.onNext(2)     // 조건 충족돼서 take 됨
    input.onNext(1)     // 조건 충족돼서 take 됨
    input.onNext(2)     // 조건 충족돼서 take 됨
    
    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number) // 조건 충족돼서 take 됨
        }
    }
    
    input.onNext(9)
}

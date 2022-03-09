import Foundation
import RxSwift
import RxRelay

// Subjects: 기본적으로 Observable은 읽기 전용
//          but 얘는 both an observable and an observer
// 1. PublishSubject: 초기값 X, only emit
// 2. BehaviorSubject: 초기값 O
// 3. ReplaySubject: 버퍼크기로 초기화
// 4. AsyncSubject

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    // subscribe 전에 이벤트 생성 따라서 출력 안됨
    subject.on(.next("Is anyone listening?"))
    
    let subscriptionOne = subject
        .subscribe(onNext: { string in
            print(string)
        })
    
    // on(.next()) == onNext()
    //: next 이벤트를 subject에 전달
    subject.on(.next("1"))
    //    subject.on(.next("Is anyone listening?"))
    subject.onNext("2")
    
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
        }
    
    // subscriptionOne에 대해 3
    // subscriptionTwo에 대해 2) 3
    // 두 번 출력
    subject.onNext("3")
    
    subscriptionOne.dispose()
    
    // subscriptionOne 종료시켰기때문에 한번만
    subject.onNext("4")
    
    // 1) 시퀀스 종료, 더 이상 이벤트를 전달X
    subject.onCompleted()
    
    // 2) 종료되었기때문에 출력 X
    subject.onNext("5")
    
    // 3) 폐기
    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()
    
    // 4) 이미 종료
    subject
        .subscribe {
            print("3)", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
}

// 1) 사용할 error type
enum MyError: Error {
    case anError
}

// 2) element or error or event 출력
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

// 3
example(of: "BehaviorSubject") {
    // 4 : 반드시 초기값 있는 애,
    //      없으면 PublishSubject 사용하거나 Optional 사용
    //      최신값
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    subject.onNext("X")
    
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    subject.onNext("X")
    
    // 1
    subject.onError(MyError.anError)
    
    // 2
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
}

example(of: "ReplaySubject") {
    // 1 : 버퍼 메모리에 유지됨
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    
    // 2
    // 버퍼 사이즈가 2이기 때문에 1은 출력 안됨
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    
    // 3) subscribe 2번, 2번씩 emit
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("4")
    //    subject.onError(MyError.anError)
    //    subject.dispose()
    
    subject
        .subscribe {
            print(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
}

example(of: "PublishRelay") {
    let relay = PublishRelay<String>()
    
    let disposeBag = DisposeBag()
    
    //Relay에 값 추가
    // only accept value 따라서 onNext 사용 X
    relay.accept("Knock knock, anyone home?")
    
    relay
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    relay.accept("1")
    //    relay.accept("Knock knock, anyone home?")
}

example(of: "BehaviorRelay") {
    // Relay는 error나 completed로 종료되지 않음
    // 1
    let relay = BehaviorRelay(value: "Initial value")
    let disposeBag = DisposeBag()
    
    // 2)
    relay.accept("New initial value")
    // 3
    relay
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 1
    relay.accept("1")
    
    // 2
    relay
        .subscribe {
            print(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    
    // 3
    relay.accept("2")
    
    print(relay.value)
}

// 도전과제 1
example(of: "PublishSubject") {
    
    let disposeBag = DisposeBag()
    
    let dealtHand = PublishSubject<[(String, Int)]>()
    
    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining = deck.count
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
            let randomIndex = Int.random(in: 0..<cardsRemaining)
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }
        
        // Add code to update dealtHand here
        let handPoints = points(for: hand)
        if handPoints > 21 {
            dealtHand.onError(HandError.busted(points: handPoints))
        } else {
            dealtHand.onNext(hand)
        }
    }
    
    // Add subscription to handSubject here
    dealtHand
        .subscribe(
            onNext: {
                print(cardString(for: $0), "for", points(for: $0), "points")
            },
            onError: {
                print(String(describing: $0).capitalized)
            })
        .disposed(by: disposeBag)
    
    deal(3)
}

// 도전과제 2
example(of: "BehaviorRelay") {
    enum UserSession {
        case loggedIn, loggedOut
    }
    
    enum LoginError: Error {
        case invalidCredentials
    }
    
    let disposeBag = DisposeBag()
    
    // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
    let userSession = BehaviorRelay(value: UserSession.loggedOut)
    
    // Subscribe to receive next events from userSession
    userSession
        .subscribe(onNext: {
            print("userSession changed:", $0)
        })
        .disposed(by: disposeBag)
    
    func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
              password == "appleseed" else {
                  completion(LoginError.invalidCredentials)
                  return
              }
        
        // Update userSession
        userSession.accept(.loggedIn)
    }
    
    func logOut() {
        // Update userSession
        userSession.accept(.loggedOut)
    }
    
    func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else {
            print("You can't do that!")
            return
        }
        
        action()
    }
    
    for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
            guard error == nil else {
                print(error!)
                return
            }
            
            print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
            print("Successfully did something only a logged in user can do.")
        }
    }
}

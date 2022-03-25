import Foundation
import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

// 현재 위치, 네트워크 연결 상태 등 현재 상태가 먼저 필요할 때 prefix
// 동일 유형만 가능
// observer가 초기 값을 즉시 얻을 수 있고 업데이트 될 것을 보장
example(of: "startWith") {
    let numbers = Observable.of(2, 3, 4)
    let observable = numbers.startWith(1)
//    let observable = numbers.startWith(1,2,3) // 여러개도 가능
    observable.subscribe(onNext: { value in
        print(value)
    })
    // 두 항목을 모두 내보내고 즉시 disposable됨
}

// 연결에 있어서 좀 더 일반적으로 사용, 순서가 좀 더 명시적
example(of: "Observable.concat") {
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)
    
    // 배열같은 observable 가변 목록을 받음
    // 중간에 에러있으면 오류 방출하고 종료
    let observable = Observable.concat([first, second])
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}
// C = A + B

// A = A + B
// instance 메소드 (class 메소드 X), 인스턴스화를 제외하고는 Observable.concat과 동일하게 작동
// 기존 observable에 적용됨
example(of: "concat") {
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    observable.subscribe(onNext: { value in
        print(value)
    })
}
// => 시퀀스를 연결하는 startWith, concat
// !유형 혼합 안됨!


// flatMap의 성능을 제공하면서 시퀀스의 순서를 보장
example(of: "concatMap") {
    let sequences = [
        "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
    ]
    
    // 국가 이름을 emit하는 시퀀스에서 각 국가별로 도시의 이름을 emit하는 시퀀스에 매핑됨
    // 국가 시퀀스 단위로 진행됨
//    let observable = Observable.of("German cities")
    let observable = Observable.of("German cities", "Spanish cities")
        .concatMap { country in sequences[country] ?? .empty() }
    
    observable.subscribe(onNext: { string in
        print(string)
    })
}

// 시퀀스 결합: 하나처럼 동작
// 소스 시퀀스가 완료되고 내부 시퀀스가 완료
// 내부 시퀀스 완료 순서는 관련X
// 하나라도 에러나면 에러 전달 후 종료 // mergeDelayError: 에러 제외하고 실행 후 에러 emit
// merge(maxConfurrent:):
example(of: "merge") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    let observable = source.merge()
    observable.subscribe(onNext: { value in
        print(value)
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    repeat {
        switch Bool.random() {
        case true where !leftValues.isEmpty:
            left.onNext("Left:  " + leftValues.removeFirst())
        case false where !rightValues.isEmpty:
            right.onNext("Right: " + rightValues.removeFirst())
        default:
            break
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    left.onCompleted()
    right.onCompleted()
}


// 합쳐진 시퀀스는 서브시퀀스에서 이벤트가 발생할 때마다 이벤트 발생
// 클로저대로 서브시퀀스들의 element를 조합하여 emit
example(of: "combineLatest") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
//    let observable = Observable
//      .combineLatest(left, right) { ($0, $1) }
//      .filter { !$0.0.isEmpty }

    let observable = Observable.combineLatest([left, right]) {
        strings in strings.joined(separator: " ")
    }
    
    observable.subscribe(onNext: { value in
        print(value)
    })
    
    // 2
    print("> Sending a value to Left")
    // 두 시퀀스가 각각 최초 이벤트를 발생시켜야 합쳐진 시퀀스에서 이벤트가 발생됨
    left.onNext("Hello,")
    // 따라서 이 문장 먼저 출력
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    left.onCompleted()
    right.onCompleted()
}

// combineLatest2
example(of: "combine user choice and value") {
    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) {
        format, when -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

// 동일한 인덱스의 observable쌍 emit, 한쪽이라도 완료되면 더이상 방출X
// index sequencing
example(of: "zip") {
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}


// 한 번에 여러 입력을 받는 경우
example(of: "withLatestFrom") {
    let button = PublishSubject<Void>() // 버튼은 실제 데이터는 없으므로 void
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    observable.subscribe(onNext: { value in
        print(value)
    })
    
    textField.onNext("Par")
//    button.onNext(())
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(()) // 버튼 탭 이벤트라 생각
}

example(of: "sample") {
    let button = PublishSubject<Void>() // 버튼은 실제 데이터는 없으므로 void
    let textField = PublishSubject<String>()
    
    let observable2 = textField.sample(button)
    observable2.subscribe(onNext: { value in
        print(value)
    })
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
    // 두 번의 탭 사이에 textField가 새 값을 내보내지 않았기 때문에 한번만 출력
}
//=> withLatestFrom: observable 데이터를 매개변수로 사용
//   sample: observable 트리거를 매개변수로 사용


// 스위치(amb, switchLatest)
// : 결합된 시퀀스의 이벤트 간 전환
// 둘 중 하나가 element를 방출할 떄 까지 기다렸다가 다른 시퀀스의 구독을 취소
// 한놈만 relay
// ex) 먼저 응답하는 서버 고수
example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = left.amb(right)
    observable.subscribe(onNext: { value in
        print(value)
    })
    
//    right.onNext("Copenhagen")
    left.onNext("Lisbon")
    right.onNext("Copenhagen")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    
    left.onCompleted()
    right.onCompleted()
}

// 가장 마지막에 푸시된 시퀀스의 항목만 emit
example(of: "switchLatest") {
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")
    
    source.onNext(two)
    one.onNext("and also from sequence one")
    two.onNext("More text from sequence two")
    
    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win.")

    source.onNext(one)
    one.onNext("Nope. It's me, one!")
    
    disposable.dispose()
}

// 결과만
// --1--2--3----|->
// -----------6-|->
example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.reduce(10) { summary, newValue in
        return summary + newValue
    }
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

// 전 과정
// --1--2--3----|->
// --1--3--6----|->
example(of: "scan") {
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.scan(0, accumulator: +)
    observable.subscribe(onNext: { value in
        print(value)
    })
}

// 도전과제
example(of: "zip") {
    let source = Observable.of(1, 3, 5, 7, 9)

    let observable = source.scan(0, accumulator: +)
    let zipObs = Observable.zip(source, observable)
    zipObs.subscribe(onNext: { source, sum in
        print(source, sum)
    })
}

example(of: "Challenge 1 - solution using just scan and a tuple") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan((0, 0)) { acc, current in
        return (current, acc.1 + current)
    }

    _ = observable.subscribe(onNext: { tuple in
        print("Value = \(tuple.0)   Running total = \(tuple.1)")
    })
}

//
//  ViewController.swift
//  RxSwift_Playground
//
//  Created by Marcos Felipe Souza on 15/02/2018.
//  Copyright © 2018 Marcos. All rights reserved.
//

import UIKit
import RxSwift

enum MyError: Error {
    case anError
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        charperOneBasics()
        
        charperTwoSubjects()
        
        charperThreeFilterOperations()
        
        charperTransformingOperations()
        
        charperCombiningOperations()
        
        
        charperTimeBasedOperator()
    }

    
    
    enum MyError: Error {
        case anError
    }
    
    
    fileprivate func charperOneBasics() {
        example(of: "just, of, from") {
            // 1
            let one = 1
            let two = 2
            let three = 3
            // 2
            let _: Observable<Int> = Observable<Int>.just(one) // envia apenas 1
            let _ = Observable.of(one, two, three) //of envia varios .next
            let _ = Observable.of([one, two, three]) //of esta enviando um array
            let _ = Observable.from([one, two, three]) // from envia apenas um object, from usado para enviar array
        }
        
        let sequence = 0..<3
        var iterator = sequence.makeIterator()
        while let n = iterator.next() {
            print(n)
        }
        
        example(of: "subscribe") { //Pega os elementos e sua finalizacao
            let one = 1
            let two = 2
            let three = 3
            let observable = Observable.of(one, two, three)
            
            observable.subscribe { event in
                print("event: \(event)")
                if let element = event.element {
                    print("event.element: \(element)")
                }
            }.disposed(by: DisposeBag())
            
            observable.subscribe(onNext: { element in
                print("element: \(element)")
            }).disposed(by: DisposeBag())
        }
        
        
        example(of: "empty") { //Emite um evento fazio, apenas com .onComplete
            let observable = Observable<Void>.empty()
            observable
                .subscribe(onNext: { element in
                        print(element)
                },onCompleted: {
                        print("Completed")
                }).disposed(by: DisposeBag())
        }
        
        //never: faz nada, não emite nenhum evento e nem recebe nada
        example(of: "never") {
            let disposeBag = DisposeBag()
            let observable = Observable<Void>.never()
            
            observable.subscribe(
                onNext: { element in
                        print(element)
                },onCompleted: {
                        print("Completed")
                })
                .disposed(by: disposeBag)
        }
        
        //range:  Cria um foreach para emitir evento
        example(of: "range") {
            
            let observable = Observable<Int>.range(start: 1, count: 10)
            observable
                .subscribe(onNext: { i in
                    
                    let n = Double(i)
                    let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
                        2.23606).rounded())
                    print(fibonacci)
                }).disposed(by: DisposeBag())
        }
        
        //dispose: Faz um DisposeBag
        example(of: "dispose") {
            
            let observable = Observable.of("A", "B", "C")
            let subscription = observable.subscribe { event in
                print(event)
            }
            subscription.dispose()
        }
        
        //DisposeBag: coloca uma mochila de dispose, para desalocar da memoria quando acabar
        // e não receber mais evento daquele subject ou observable
        example(of: "DisposeBag") {
            
            let disposeBag = DisposeBag()
            
            Observable.of("A", "B", "C")
                .subscribe {
                    print($0) }
                .disposed(by: disposeBag)
            //@available(*, deprecated, message: "use disposed(by:) instead", renamed: "disposed(by:)")
        }
        
        //create: Cria um observebled e um observer para ele msmo
        example(of: "create") {
            
            Observable<String>.create { observer in
                observer.onNext("1")
                
                // finaliza com erro ou com complete
                observer.onError(MyError.anError)
                observer.onCompleted()
                
                //Depois de completar isso nao printa
                observer.onNext("?")
                
                //SEmpre deve retornar um disposable, sempre desaloca
                return Disposables.create()
                }
                //Get o return do Observable.create
                .subscribe(
                    onNext: { print($0) },
                    onError: { print($0) },
                    onCompleted: { print("Completed") },
                    onDisposed: { print("Disposed") }
                ).disposed(by: DisposeBag())
            
            
        }
        
        
        
        example(of: "deferred") {
            let disposeBag = DisposeBag()
            // 1
            var flip = false
            // 2
            let factory: Observable<Int> = Observable.deferred {
                // 3
                flip = !flip
                // 4
                if flip {
                    return Observable.of(1, 2, 3)
                } else {
                    return Observable.of(4, 5, 6)
                }
            }
            for _ in 0...3 {
                factory.subscribe(onNext: {
                    print($0, terminator: "")
                }).disposed(by: disposeBag)
                print()
                
            }
        }
    }
    
    func charperTwoSubjects() {
        example(of: "PublishSubject") {
            //Fica publicando Subjects
            let subject = PublishSubject<String>()
            subject.onNext("Is anyone listening?")
            
            let subscriptionOne = subject
                .subscribe(onNext: { string in
                    print("subscriptionOne:\(string)")
                })
            
            subject.on(.next("1"))
            subject.onNext("2")
            
            let subscriptionTwo = subject
                .subscribe { event in
                    print("subscriptionTwo:", event.element ?? event)
            }
            
            subject.onNext("3")
            subscriptionOne.dispose()
            subject.onNext("4")
            
            // subscription 2 is cancelled in this moment
            subject.onCompleted()
            // 2
            subject.onNext("5")
            // 3
            subscriptionTwo.dispose()
            let disposeBag = DisposeBag()
            // 4
            subject
                .subscribe {
                    print("3)", $0.element ?? $0)
                }
                .disposed(by: disposeBag)
            
            _ = subject
                .subscribe { event in
                    print("4)", event.element ?? event)
            }
            
            
            subject.onNext("?")
        }
        
        
        // 1
      
        // 2
        //        func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
        //            print(label: label, event: event.element ?? event.error ?? event)
        //        }
        
        // BehaviorSubject is equals to PublishSubject, but it show the last subject
        example(of: "BehaviorSubject") {
            // 4
            let subject = BehaviorSubject(value: "Initial value")
            let disposeBag = DisposeBag()
            subject
                .subscribe {
                    self.printaum(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)
            
            subject.onNext("X")
            
            // 1
            subject.onError(MyError.anError)
            // 2
            subject
                .subscribe {
                    self.printaum(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)
            
        }
        
        
        example(of: "ReplaySubject") {
            // Mesmo que os outros de cima, o unico problema é que ele guarda todos os eventos
            // e dispara para os novos todos os eventos, menos error. Bom utiliza-lo com bufferSize: que limita
            // a quantidade de eventos guardados
            let subject = ReplaySubject<String>.create(bufferSize: 2)
            let disposeBag = DisposeBag()
            // 2
            subject.onNext("1")
            subject.onNext("2")
            subject.onNext("3")
            // 3
            subject
                .subscribe {
                    self.printaum(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)
            subject
                .subscribe {
                    self.printaum(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)
            
            subject.onNext("4")
            
            subject.onError(MyError.anError) //termina a observacao
            
            subject
                .subscribe {
                    self.printaum(label: "3)", event: $0)
                }.disposed(by: disposeBag)
        }
        
        //Variable: não tem .onCompleted e nem .onError apenas notifica todos qndo seu valor muda
        // apenas existe .onNext
        example(of: "Variable") {
            // 1
            let variable = Variable("Initial value")
            let disposeBag = DisposeBag()
            // 2
            variable.value = "New initial value"
            // 3
            variable.asObservable()
                .subscribe {
                    self.printaum(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)
            
            // 1
            variable.value = "1"
            // 2
            variable.asObservable()
                .subscribe {
                    self.printaum(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)
            // 3
            variable.value = "2"
        }
    }
    
    fileprivate func charperThreeFilterOperations() {
        
        //Ignora os elementos em .onNext , pegando apenas o final
        // onCompleted e o onError.
        example(of: "ignoreElements") {
            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()
            strikes.ignoreElements()
                    .subscribe { _ in
                        print("You're out!")
                    }
                    .disposed(by: disposeBag)
            
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onCompleted()
        }
        
        //elementAt: ignora todos no .onNext menos o da posicao do At,
        // e pega tbm o onComplete e o onError
        example(of: "elementAt") {
            // 1
            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()
            // 2
            strikes.elementAt(2)
                    .subscribe(onNext: { _ in
                        print("You're out!")
                    })
                    .disposed(by: disposeBag)
            
            strikes.onNext("X")
            strikes.onNext("X")
            strikes.onNext("X")
        }
        
        //filter: coloca um filtro, onde,
        // so passa no onNext, caso a condicação do filter for valida
        example(of: "filter") {
            let disposeBag = DisposeBag()
            Observable.of(1, 2, 3, 4, 5, 6)
                      .filter { integer in
                            integer % 2 == 0
                        }
                        //So passa se passar pelo filtro no .subscribe
                        .subscribe(onNext: {
                            print($0)
                        })
                        .disposed(by: disposeBag)
        }
        
        //skip: Apenas pega o valor dos proximos next de acordo com o numero
        example(of: "skip") {
            let disposeBag = DisposeBag()
            
            Observable.of("A", "B", "C", "D", "E", "F")
                .skip(3)
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
        }
        
        //skipWhile: vai deixar skip até qndo a condição for valida,
        // depois que for valida, vai passar todos
        example(of: "skipWhile") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(2, 2, 3, 4, 4)
                // 2
                .skipWhile { integer in
                    integer % 2 == 0
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        //skipUntil: Vai skipt até achar uma condição de poder exibir
        example(of: "skipUntil") {
            let disposeBag = DisposeBag()
            // 1
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            // 2
            subject
                .skipUntil(trigger)
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
            
            subject.onNext("A")
            subject.onNext("B")
            trigger.onNext("X") //start print
            subject.onNext("C")
            subject.onNext("D")
            trigger.onNext("Z") //doesnt stop
            subject.onNext("E")
            subject.onNext("F")
            trigger.onCompleted() // continue print
            subject.onNext("G")
            subject.onNext("H")
        }
        
        //take: Pega os primeiros elementos até o index indicado
        example(of: "take") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(1, 2, 3, 4, 5, 6)
                // 2
                .take(3)
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
        }
        
        //takeWhile: é igual ao skipWhile sendo que ele não skip e sim take
        //takeWhileWithIndex: faz extamente igual o takeWhile com index.
        // vc pega o valor e seu index.
        example(of: "takeWhileWithIndex") {
            let disposeBag = DisposeBag()
            
            Observable.of(2, 2, 4, 4, 6, 6)
                .takeWhileWithIndex { integer, index in
                    integer % 2 == 0 && index < 3 //todos os pares abaixo do index 3
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        //takeUntil: igual o skipUntil , sendo que o skipUntil eh para esquecer(skip)
        // e o take é para pegar(take)
        example(of: "takeUntil") {
            let disposeBag = DisposeBag()
            
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            
            subject
                .takeUntil(trigger)
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
            
            
            subject.onNext("1")
            subject.onNext("2")
            trigger.onNext("X")
            subject.onNext("3")
        }
        
        //distinctUntilChanged: serve para nao repetir os valores sequencias
        example(of: "distinctUntilChanged") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of("A", "A", "B", "B", "B", "A")
                // 2
                .distinctUntilChanged()
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
        }
        
        //distinctUntilChanged(_:): Usado qndo os .next não são Equatable (String são),
        // os objetos devem ser tratados.
        example(of: "distinctUntilChanged(_:)") {
            let disposeBag = DisposeBag()
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            
            Observable<NSNumber>.of(10, 10, 10, 110, 20, 20, 200, 210, 310)
                .distinctUntilChanged { a, b in
                    
                    guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                        let bWords = formatter.string(from: b)?.components(separatedBy: "")
                            else {
                            return false
                    }
                    var containsMatch = false
                    // 5
                    for aWord in aWords {
                        for bWord in bWords {
                            if aWord == bWord {
                                containsMatch = true
                                break
                            }
                        }
                    }
                    return containsMatch
                }
                
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
    }
    
    
    func charperTransformingOperations() {
        example(of: "toArray") {
            let disposeBag = DisposeBag()
            
            
            Observable.of("A", "B", "C")
                .toArray()
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
        }
        
        example(of: "map") {
            let disposeBag = DisposeBag()
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            formatter.locale = Locale(identifier: "pt_BR")
            Observable<NSNumber>.of(123, 4, 56)
                .map {
                    formatter.string(from: $0) ?? ""
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(of: "mapWithIndex") {
            let disposeBag = DisposeBag()
            
            Observable.of(1, 2, 3, 4, 5, 6).mapWithIndex({ integer, index in
                index > 2 ? integer * 2 : integer
                })
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        //flatMap: Adiciona os Subriscreb e qndo altera o valor , manda para todos
        example(of: "flatMap") {
            let disposeBag = DisposeBag()
            // 1
            let ryan = Student(score: Variable(80))
            let charlotte = Student(score: Variable(90))
            // 2
            let student = PublishSubject<Student>()
            // 3
            student.asObservable()
                .flatMap {
                    $0.score.asObservable()
                }
                // 4
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            student.onNext(ryan)
            ryan.score.value = 85
            
            student.onNext(charlotte)
            ryan.score.value = 95
            charlotte.score.value = 100
            
        }
        
        //flatMapLatest: So repassa a observacao do ultimo Observavel adicionado.
        // serve mais para operacoes em Network, usado mais qndo vc vai buscar
        // s, w, i, f, t , pegando sempre os ultimos valores e esquecendo os demais.
        example(of: "flatMapLatest") {
            let disposeBag = DisposeBag()
            let ryan = Student(score: Variable(80))
            let charlotte = Student(score: Variable(90))
            let student = PublishSubject<Student>()
            student.asObservable()
                .flatMapLatest {
                    $0.score.asObservable()
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            student.onNext(ryan)
            ryan.score.value = 85
            student.onNext(charlotte)
            // 1
            ryan.score.value = 95
            charlotte.score.value = 100
        }
        
    }
    
    func charperCombiningOperations() {
        
        //StartWith: Coloca um valor no inicio das obervacoes
        example(of: "startWith") {
            // 1
            let numbers = Observable.of(2, 3, 4)
            // 2
            let observable = numbers.startWith(1)
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
        //Concat: Concatena os valores dos subscribles
        example(of: "Observable.concat") {
            // 1
            let first = Observable.of(1, 2, 3)
            let second = Observable.of(4, 5, 6, 7, 8)
            // 2
            let observable = Observable.concat([first, second])
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
        
        //Concat: Concatena os valores dos subscribles
        example(of: "concat") {
            let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
            let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
            let observable = germanCities.concat(spanishCities)
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
        
        //Concat: Concatena os valores com o just, o just eh posto no inicio das concatenacoes
        example(of: "concat one element") {
            let numbers = Observable.of(2, 3, 4)
            let observable = Observable
                .just(1)
                .concat(numbers)
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
        
        //merge: junta as duas observer em uma so
        example(of: "merge") {
            // 1
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            
            let source = Observable.of(left.asObservable(), right.asObservable())
            
            // 3
            let observable = source.merge()
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            // 4
            var leftValues = ["Berlin", "Munich", "Frankfurt"]
            var rightValues = ["Madrid", "Barcelona", "Valencia"]
            repeat {
                if arc4random_uniform(2) == 0 {
                    if !leftValues.isEmpty {
                        left.onNext("Left:  " + leftValues.removeFirst())
                    }
                } else if !rightValues.isEmpty {
                    right.onNext("Right: " + rightValues.removeFirst())
                }
            } while !leftValues.isEmpty || !rightValues.isEmpty
            
            disposable.dispose()
        }
        
        //CombineLatest: faz o merger sempre dos ultimos valores ja com o ultimo valor,
        // qndo for alterado ele pega o antigo e o novo do alterado
        example(of: "combineLatest") {
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            // 1
            let observable = Observable.combineLatest(left, right, resultSelector: {
                lastLeft, lastRight in
                "\(lastLeft) \(lastRight)"
            })
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            left.onNext("Hello,")
            right.onNext("world")
            
            right.onNext("RxSwift")
            
            left.onNext("Have a good day,")
            
            disposable.dispose()
        }
        
        //combine: Exemplo de como utilizar o combine
        example(of: "combine user choice and value") {
            let choice : Observable<DateFormatter.Style> =
                Observable.of(.short, .long)
            let dates = Observable.of(Date())
            let observable = Observable.combineLatest(choice, dates) {
                (format, when) -> String in
                let formatter = DateFormatter()
                formatter.dateStyle = format
                return formatter.string(from: when)
            }
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
        
        //zip: Sempre junta qndo tiverem os 2 valores, qndo tiverem os mesmos valores nos observaveis
        //exemplo: obs1 [0,1,2] e o obs2 [3,4] o obs1[2] não vai aparecer com o zip
        example(of: "zip") {
            enum Weather {
                case cloudy
                case sunny }
            let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy,
                                                          .sunny)
            let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid",
                                      "Vienna")
            let observable = Observable.zip(left, right) { weather, city in
                return "It's \(weather) in \(city)"
            }
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
            
        }
        
        //withLatesFrom: Eh uma trigger, lanca uma trigger.
        example(of: "withLatestFrom") {
            // 1
            let button = PublishSubject<String>()
            let textField = PublishSubject<String>()
            // 2
            let observable = button.withLatestFrom(textField)
            _ = observable.subscribe(onNext: { value in
                print(value)
            })
            // 3
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext("")
            button.onNext("")
        }
        
        //sample: Eh uma trigger, lanca uma trigger, mas se o valor novo for diferente do ultimo.
        example(of: "sample") {
            // 1
            let button = PublishSubject<String>()
            let textField = PublishSubject<String>()
            // 2
            let observable = textField.sample(button)
            //let observable = button.withLatestFrom(textField)
            _ = observable.subscribe(onNext: { value in
                print(value)
            })
            // 3
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext("")
            button.onNext("")
        }
        
        example(of: "amb") {
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            // 1
            let observable = left.amb(right)
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            // 2
            left.onNext("Lisbon")
            right.onNext("Copenhagen")
            
            left.onNext("London")
            left.onNext("Madrid")
            
            right.onNext("Vienna")
            right.onNext("Madrid")
            left.onNext("Vienna")
            disposable.dispose()
        }
       
        //switchLatest: so esculta o tipo do objeto que tiver no next.
        example(of: "switchLatest") {
            // 1
            let one = PublishSubject<String>()
            let two = PublishSubject<String>()
            let three = PublishSubject<String>()
            let source = PublishSubject<Observable<String>>()
            
            // 2
            let observable = source.switchLatest()
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            
            // 3
            source.onNext(one)
            one.onNext("Some text from sequence one")
            two.onNext("Some text from sequence two")
            
            source.onNext(two)
            two.onNext("More text from sequence two")
            one.onNext("and also from sequence one")
            
            source.onNext(three)
            two.onNext("Why don't you seem me?")
            one.onNext("I'm alone, help me")
            three.onNext("Hey it's three. I win.")
            
            source.onNext(one)
            one.onNext("Nope. It's me, one!")
            
            disposable.dispose()
        }
        
        //reduce: vai somando, com o valor inicial e o ja na lista
        example(of: "reduce") {
            let source = Observable.of(1, 3, 5, 7, 9)
            // 1
            let observable = source.reduce(0, accumulator: +)
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
        
        //scan: vai somando com o valor inicial e podendo intervir nas contas
        example(of: "scan") {
            let source = Observable.of(1, 3, 5, 7, 9)
            let observable = source.scan(0, accumulator: +)
            observable.subscribe(onNext: { value in
                print(value)
            }).disposed(by: DisposeBag())
        }
    }
    
    
    func charperTimeBasedOperator() {
        let elementsPerSeconds = 1
        let maxElements = 5
        let replayedElements = 1
        let replayDelay: TimeInterval = 3
        
//        let sourceObservable = Observable<Int>.create { observer in
//            var value = 1
//            
//            DispatchSource.makeTimerSource().
//            
//            let time = DispatchSource.timer(interval: 1.0 / Double(elementsPerSeconds), queue: .main) {
//                if value <= maxElements {
//                    observer.onNext(value)
//                    value += 1
//                }
//            }
//            return Disposables.create {
//                timer.suspend()
//            }
//        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func printaum<T: CustomStringConvertible>(label: String, event: Event<T>) {
        guard let event: Event<T> = event else { return }
        print(label, (event.element ?? event.error ?? "erro"))
    }
    
    public func example(of description: String, action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }
}


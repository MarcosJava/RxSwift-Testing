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
        
        //charperTwoSubjects()
        
        //charperThreeFilterOperations()
        
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
                    print(string)
                })
            
            subject.on(.next("1"))
            subject.onNext("2")
            
            let subscriptionTwo = subject
                .subscribe { event in
                    print("2)", event.element ?? event)
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
            // e dispara para os novos todos os eventos. Bom utiliza-lo com bufferSize: que limita
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
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func printaum<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label, event.element ?? event.error ?? event)
    }
    
    public func example(of description: String, action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }
}


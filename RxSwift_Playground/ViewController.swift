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
    
    enum MyError: Error {
        case anError
    }
    
    
    fileprivate func charperOne() {
        example(of: "just, of, from") {
            // 1
            let one = 1
            let two = 2
            let three = 3
            // 2
            let observable: Observable<Int> = Observable<Int>.just(one)
            let observable2 = Observable.of(one, two, three)
            let observable3 = Observable.of([one, two, three])
            let observable4 = Observable.from([one, two, three])
        }
        
        let sequence = 0..<3
        var iterator = sequence.makeIterator()
        while let n = iterator.next() {
            print(n)
        }
        
        example(of: "subscribe") {
            let one = 1
            let two = 2
            let three = 3
            let observable = Observable.of(one, two, three)
            
            //            observable.subscribe { event in
            //                if let element = event.element {
            //                    print(element)
            //                }
            //            }
            
            observable.subscribe(onNext: { element in
                print(element)
            })
        }
        
        
        example(of: "empty") {
            let observable = Observable<Void>.empty()
            observable
                .subscribe(
                    // 1
                    onNext: { element in
                        print(element)
                },
                    // 2
                    onCompleted: {
                        print("Completed")
                })
        }
        
        example(of: "never") {
            let disposeBag = DisposeBag()
            let observable = Observable<Void>.never()
            observable
                .subscribe(
                    // 1
                    onNext: { element in
                        print(element)
                },
                    // 2
                    onCompleted: {
                        print("Completed")
                })
                .disposed(by: disposeBag)
        }
        
        
        example(of: "range") {
            // 1
            let observable = Observable<Int>.range(start: 1, count: 10)
            observable
                .subscribe(onNext: { i in
                    // 2
                    let n = Double(i)
                    let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
                        2.23606).rounded())
                    print(fibonacci)
                })
        }
        
        example(of: "dispose") {
            // 1
            let observable = Observable.of("A", "B", "C")
            // 2
            let subscription = observable.subscribe { event in
                // 3
                print(event)
            }
            subscription.dispose()
        }
        
        example(of: "DisposeBag") {
            // 1
            let disposeBag = DisposeBag()
            // 2
            Observable.of("A", "B", "C")
                .subscribe { // 3
                    print($0) }
                .disposed(by: disposeBag) // 4
            //@available(*, deprecated, message: "use disposed(by:) instead", renamed: "disposed(by:)")
        }
        
        example(of: "create") {
            
            Observable<String>.create { observer in
                // 1
                observer.onNext("1")
                // 2
                // observer.onError(MyError.anError)
                
                // observer.onCompleted()
                // 3
                observer.onNext("?")
                // 4
                
                return Disposables.create()
                }
                .subscribe(
                    onNext: { print($0) },
                    onError: { print($0) },
                    onCompleted: { print("Completed") },
                    onDisposed: { print("Disposed") }
            )
            // .addDisposableTo(disposeBag)
            
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
            // 1
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //charperOne()
        
        //charperTwoSubjects()
        
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


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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func example(of description: String, action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }
}


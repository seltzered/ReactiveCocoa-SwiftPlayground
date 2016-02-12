//: Playground - noun: a place where people can play

// TODO - this is an unfinished demo.
//
//code taken from example at: http://blog.scottlogic.com/2015/02/11/swift-kvo-alternatives.html
// and correction based on: http://stackoverflow.com/questions/31308209/error-with-override-public-func-observevalueforkeypath

import Cocoa

class Car: NSObject {
    dynamic var miles = 0
    dynamic var name = "Turbo"
}

class CarObserver: NSObject {
    
    private var kvoContext: UInt8 = 1
    
    private let car: Car
    
    init(_ car: Car) {
        self.car = car
        super.init()
        car.addObserver(self, forKeyPath: "miles",
            options: NSKeyValueObservingOptions.New, context: &kvoContext)
    }
    
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            if context == &kvoContext {
                print("Change at keyPath = \(keyPath) for \(object)")
            }
    }
    
    deinit {
        car.removeObserver(self, forKeyPath: "miles")
    }
}

let myCar :Car = Car.init()

let myCarObserver :CarObserver = CarObserver.init(myCar)

myCar.miles = 2

//---- doing the same thing Reactively

import ReactiveCocoa

class ReactiveCarObserver: NSObject {
    
    private var kvoContext: UInt8 = 1
    
    private let car: Car
    
    init(_ car: Car) {
        self.car = car
        super.init()
        car.addObserver(self, forKeyPath: "miles",
            options: NSKeyValueObservingOptions.New, context: &kvoContext)
    }
    
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            if context == &kvoContext {
                print("Change at keyPath = \(keyPath) for \(object)")
            }
    }
    
    deinit {
        car.removeObserver(self, forKeyPath: "miles")
    }
}






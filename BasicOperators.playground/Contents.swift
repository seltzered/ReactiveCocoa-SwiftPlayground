//: ## Reactive Cocoa - Basic Operators
//:
//: This playground is based on the Reactive Cocoa [Basic Operators documentation](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/BasicOperators.md)
//:
//: ---
//:
//: This document is read best as rich text. Select the Editor -> Show Rendered Markup to see this playground with markup rendered.
//: Due to issues seen with playgrounds results quicklook, it's currently recommended to only look at results in the console output window.
//: Marble diagrams taken from: http://neilpa.me/rac-marbles/

import Cocoa
import ReactiveCocoa

func sectionStr(sectionName :String) -> String
{
    let secStrLen = sectionName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    let dividerStr = String( [Character](count:secStrLen, repeatedValue: "-"))
    return ("\n" + dividerStr + "\n" + sectionName + "\n" + dividerStr + "\n")
}
var buffer :String

//:
//: ### Transforming - map
// ![](racmarbles-map.png)
//
buffer = sectionStr("Transforming - map")

let (mapSignal, mapObserver) = Signal<Int, NoError>.pipe()

let signalMultiplied = mapSignal.map { number in
    return number * 10
}

signalMultiplied.observeNext { next in
    buffer = buffer + String(next) + "\n"
}

mapObserver.sendNext(1)
mapObserver.sendNext(2)
mapObserver.sendNext(3)

print(buffer)

//The signal could also be simplified down to:
//
// mapSignal
//    .map { number in number * 10 }
//    .observeNext { next in print(next) }
//

//: ### Transforming - filter
// ![](racmarbles-filter.png)
//
buffer = sectionStr("Transforming - filter")

let (filterSignal, filterObserver) = Signal<Int, NoError>.pipe()

filterSignal
    .filter { number in number > 10 }
    .observeNext { filteredVal in buffer = buffer + String(filteredVal) + "\n" }

filterObserver.sendNext(2)
filterObserver.sendNext(30)
filterObserver.sendNext(22)
filterObserver.sendNext(5)
filterObserver.sendNext(60)
filterObserver.sendNext(1)

print(buffer)

//: ### Aggregating - reduce
//:
buffer = sectionStr("Aggregating - reduce")

let (reduceSignal, reduceObserver) = Signal<Int, NoError>.pipe()

reduceSignal
    .reduce( 1, { reduced, next in reduced + next } )
    .observeNext { reducedResult in buffer = buffer + String(reducedResult) + "\n" }

reduceObserver.sendNext(1)
reduceObserver.sendNext(2)
reduceObserver.sendNext(3)
reduceObserver.sendCompleted() //prints sum

print(buffer)

//: ### Aggregating - collect
//:
buffer = sectionStr("Aggregating - collect")

let (collectSignal, collectObserver) = Signal<Int, NoError>.pipe()

collectSignal
    .collect()
    .observeNext { collected in buffer = buffer + String(collected) + "\n" }

collectObserver.sendNext(1)
collectObserver.sendNext(2)
collectObserver.sendNext(3)
collectObserver.sendCompleted() 

print(buffer)

//: ### Combining - combine latest
//:
buffer = sectionStr("Combining - combineLatest")

let (numbersToCombineSignal, numbersToCombineObserver) = Signal<Int, NoError>.pipe()
let (lettersToCombineSignal, lettersToCombineObserver) = Signal<String, NoError>.pipe()

numbersToCombineSignal
    .combineLatestWith(lettersToCombineSignal)
    .observe { combinedEvent -> () in
        switch combinedEvent {
        case let .Next(number, letter):
            buffer = buffer + "number: " + String(number) + " letter: " + String(letter) + "\n"
        case .Failed:
            buffer = buffer + "failed\n"
        case .Completed:
            buffer = buffer + "completed\n"
        case .Interrupted:
            buffer = buffer + "interrupted\n"
        }
}

numbersToCombineObserver.sendNext(0)      // nothing printed, no letter yet
numbersToCombineObserver.sendNext(1)      // nothing printed, no letter yet
lettersToCombineObserver.sendNext("A")     // prints (1, A)
numbersToCombineObserver.sendNext(2)      // prints (2, A)
numbersToCombineObserver.sendCompleted() // nothing printed
lettersToCombineObserver.sendNext("B")    // prints (1, B)
lettersToCombineObserver.sendNext("C")    // prints (2, C) 
lettersToCombineObserver.sendCompleted()  // prints completed

print(buffer)

//: ### Combining - Zipping
//:
buffer = sectionStr("Combining - zip")

let (numbersToZipSignal, numbersToZipObserver) = Signal<Int, NoError>.pipe()
let (lettersToZipSignal, lettersToZipObserver) = Signal<String, NoError>.pipe()

numbersToZipSignal
    .zipWith(lettersToZipSignal)
    .observe {  event in
        switch event {
        case let .Next(zipVal):
            buffer = buffer + "zipval: " + String(zipVal) + "\n"
        case .Failed:
            buffer = buffer + "failed\n"
        case .Completed:
            buffer = buffer + "completed\n"
        case .Interrupted:
            buffer = buffer + "interrupted\n"
    }
}

numbersToZipObserver.sendNext(0)      // nothing printed
numbersToZipObserver.sendNext(1)      // nothing printed
lettersToZipObserver.sendNext("A")    // prints (0, A)
numbersToZipObserver.sendNext(2)      // nothing printed
numbersToZipObserver.sendCompleted()  // nothing printed
lettersToZipObserver.sendNext("B")    // prints (1, B)
lettersToZipObserver.sendNext("C")    // prints (2, C) & "Completed"

print(buffer)


//: ### Flattening - concatenate
//:
//: experiment with commenting out completion events, adjusting buffer sizes.

buffer = sectionStr("Flattening - Concatenate")

let (innerConcatA, innerConcatAObserver) = SignalProducer<String, NoError>.buffer(5)
let (innerConcatB, innerConcatBObserver) = SignalProducer<String, NoError>.buffer(1)
let (concatSigProd, concatObserver) = SignalProducer<SignalProducer<String, NoError>, NoError>.buffer(5)

concatSigProd.flatten(.Concat)
    .start { event in
        switch event {
        case let .Next(concatValue):
            buffer = buffer + "concat next: " + String(concatValue) + "\n"
        case .Failed:
            buffer = buffer + "failed\n"
        case .Completed:
            buffer = buffer + "completed\n"
        case .Interrupted:
            buffer = buffer + "interrupted\n"
        }
}

concatObserver.sendNext(innerConcatA)
concatObserver.sendNext(innerConcatB)
concatObserver.sendCompleted()

innerConcatAObserver.sendNext("A")
innerConcatBObserver.sendNext("1")
innerConcatBObserver.sendNext("2")
innerConcatBObserver.sendNext("3")
innerConcatAObserver.sendNext("B")
innerConcatAObserver.sendCompleted()
innerConcatBObserver.sendNext("4")
innerConcatBObserver.sendCompleted()

print(buffer)


//: ### Flattening - merge
//:
buffer = sectionStr("Flattening - Merging")

let (innerMergeA, innerMergeAObserver) = SignalProducer<String, NoError>.buffer(5)
let (innerMergeB, innerMergeBObserver) = SignalProducer<String, NoError>.buffer(5)
let (mergeSigProd, mergeObserver) = SignalProducer<SignalProducer<String, NoError>, NoError>.buffer(5)

mergeSigProd.flatten(.Merge)
    .start { event in
        switch event {
        case let .Next(concatValue):
            buffer = buffer + "concat next: " + String(concatValue) + "\n"
        case .Failed:
            buffer = buffer + "failed\n"
        case .Completed:
            buffer = buffer + "completed\n"
        case .Interrupted:
            buffer = buffer + "interrupted\n"
        }
}

mergeObserver.sendNext(innerMergeA)

innerMergeAObserver.sendNext("A")
innerMergeBObserver.sendNext("1")
innerMergeBObserver.sendNext("2")
innerMergeAObserver.sendNext("B")
mergeObserver.sendNext(innerMergeB) //merges, and forwards any buffered events
innerMergeBObserver.sendNext("3")
innerMergeAObserver.sendNext("C")
innerMergeAObserver.sendCompleted()
innerMergeBObserver.sendNext("4")
innerMergeBObserver.sendCompleted()

print(buffer)


//: ### Flattening - latest
//: (a.k.a. switchToLatest)
//:
buffer = sectionStr("Flattening - Latest")

let (innerLatestA, innerLatestAObserver) = SignalProducer<String, NoError>.buffer(5)
let (innerLatestB, innerLatestBObserver) = SignalProducer<String, NoError>.buffer(5)
let (latestSigProd, latestObserver) = SignalProducer<SignalProducer<String, NoError>, NoError>.buffer(5)

latestSigProd.flatten(.Latest)
    .start { event in
        switch event {
        case let .Next(concatValue):
            buffer = buffer + "concat next: " + String(concatValue) + "\n"
        case .Failed:
            buffer = buffer + "failed\n"
        case .Completed:
            buffer = buffer + "completed\n"
        case .Interrupted:
            buffer = buffer + "interrupted\n"
        }
}

latestObserver.sendNext(innerLatestA)

innerLatestAObserver.sendNext("A")
innerLatestBObserver.sendNext("1")
innerLatestBObserver.sendNext("2")
innerLatestAObserver.sendNext("B")
latestObserver.sendNext(innerLatestB) //switch latest, and forwards any buffered events
innerLatestBObserver.sendNext("3")
innerLatestAObserver.sendNext("C")   //not printed
innerLatestAObserver.sendCompleted()
innerLatestBObserver.sendNext("4")
innerLatestBObserver.sendCompleted()

print(buffer)

//: ### Flattening - using a Signal-of-SignalProducers
//:
buffer = sectionStr("Flattening - using a Signal-of-SignalProducers")

let (innerSigProdA, innerSigProdAObserver) = SignalProducer<String, NoError>.buffer(1)
let (innerSigProdB, innerSigProdBObserver) = SignalProducer<String, NoError>.buffer(1)
let (sigOfSigProds, sigOfSigProdsObserver) = Signal<SignalProducer<String, NoError>, NoError>.pipe()

sigOfSigProds.flatten(.Merge)
    .observeNext {next in
        buffer = buffer + "merged next:\(next)\n"
}

sigOfSigProdsObserver.sendNext(innerSigProdA)
innerSigProdAObserver.sendNext("hi")          //prints hi
innerSigProdBObserver.sendNext("1")          //prints nothing
sigOfSigProdsObserver.sendNext(innerSigProdB)  //prints latest as long as buffer size >= 1

print(buffer)

//: ### Flattening - using a Signal-of-Signals
//:
buffer = sectionStr("Flattening - using a Signal-of-Signals")

let (innerSigA, innerSigAObserver) = Signal<String, NoError>.pipe()
let (innerSigB, innerSigBObserver) = Signal<String, NoError>.pipe()
let (sigOfSigs, sigofSigObserver) = Signal<Signal<String, NoError>, NoError>.pipe()

sigOfSigs.flatten(.Merge)
    .observeNext {next in
        buffer = buffer + "merged next:\(next)\n"
}

sigofSigObserver.sendNext(innerSigA)
innerSigAObserver.sendNext("A")          //prints hi
innerSigBObserver.sendNext("1")          //prints nothing
sigofSigObserver.sendNext(innerSigB)     //prints nothing since a signal has no buffer
innerSigBObserver.sendNext("2")          //prints 2

print(buffer)

//: ### Flattening - using a SignalProducer-of-Signals
//:
buffer = sectionStr("Flattening - using a SignalProducer-of-Signals")

let (innerSigC, innerSigCObserver) = Signal<String, NoError>.pipe()
let (innerSigD, innerSigDObserver) = Signal<String, NoError>.pipe()
let (sigProdOfSigs, sigProdOfSigsObserver) = SignalProducer<Signal<String, NoError>, NoError>.buffer(1)

sigProdOfSigs.flatten(.Merge)
    .startWithNext{next in
        buffer = buffer + "merged next:\(next)\n"
}

sigProdOfSigsObserver.sendNext(innerSigC)
innerSigCObserver.sendNext("hi")           //prints hi
innerSigDObserver.sendNext("1")            //prints nothing
sigProdOfSigsObserver.sendNext(innerSigD) //prints nothing since a signal has no buffer
innerSigDObserver.sendNext("4")            //prints 4

print(buffer)

//: ### Chaining - then (signalProducer-only method)
//:
//: then will execute the previous signal *then* when it's completed start the next. previous signal next value output is suppressed
//: this may be useful for say, a login popup required before performing
//:
buffer = sectionStr("Chaining - SignalProducer.then")

let sigProdFirst = SignalProducer<String, NSError>.init { (observer, compositeDisposable) -> () in
    
    //do some initial stuff here
    observer.sendNext("knock\n")
    observer.sendNext("knock\n")
    observer.sendCompleted()  //comment this out and try sendFailed
//    observer.sendFailed(NSError(domain: "then example", code: 1, userInfo: nil))
}

sigProdFirst
    .then(SignalProducer<String, NSError>.init { (observer, compositeDisposable) -> () in
        //do post-completion stuff here
        observer.sendNext("and then... \n")
        observer.sendNext("there was success")
        })
    .startWithNext{ next in
        buffer = buffer + next
    }

print(buffer)

//: ### Chaining - concat (signalProducer-only method)
//:
buffer = sectionStr("Chaining - SignalProducer.concat")

sigProdFirst
    .concat(SignalProducer<String, NSError>.init { (observer, compositeDisposable) -> () in
        //do post-completion stuff here
        observer.sendNext("who's there?")
        })
    .startWithNext{ next in
        buffer = buffer + next
    }

print(buffer)


//: ## Timing
//:
//: TODO

//: ## Lifting
//:
//: TODO

//: ## Mapping / Promoting Errors
//:
//: TODO


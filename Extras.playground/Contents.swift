//: Playground - noun: a place where people can play

import Cocoa
import ReactiveCocoa

func printSection(sectionName :String)
{
    let secStrLen = sectionName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    let dividerStr = String( [Character](count:secStrLen, repeatedValue: "-"))
    print("\n" + dividerStr )
    print(sectionName)
    print(dividerStr + "\n")
}

//: ## extras

//: ### extras - signal init without pipe()
//: Demo of doing your own Signal init if you really wanted to perform a pre-amble of things before the signal is created.
//: At the moment I can't see why you'd want to do this over performing such things outside the init.
//:
//

printSection("Extras - alternative signal init")
var customInitObserver :Observer<Int, NoError>!
var signalCustomInit :Signal<Int, NoError> = Signal.init { (observer) -> Disposable? in
    
    //do some initial stuff here
    observer.sendNext(0) //won't print anything since you won't have your observeNext occur
    
    customInitObserver = observer
    return nil
}

signalCustomInit.observeNext({ number in print(number) })
customInitObserver.sendNext(1) //prints 1


//: [Previous](@previous)

import Foundation

var greeting = "Hello, Tasks"

func example_1(){
    let basicTask = Task { @MainActor in
        // Executes async
        print("BasicTask start \(Thread.current)")
        try! await Task.sleep(nanoseconds: 1_000_000_000)
        print("BasicTask end")
        return "This is the result of the task"
    }
    
    Task {
        print("Task start \(Thread.current)")
        
        print(await basicTask.value)
        print("Task end \(Thread.current)")
    }
    
    print("Example 1 \(Thread.current)")
}

/* example_1 result
 
 Task start <NSThread: 0x600001709d80>{number = 3, name = (null)}
 Example 1 <_NSMainThread: 0x600001700000>{number = 1, name = main}
 BasicTask start <_NSMainThread: 0x600001700000>{number = 1, name = main}
 BasicTask end
 This is the result of the task
 Task end <NSThread: 0x60000171c000>{number = 8, name = (null)}
 */
 
//example_1()


struct Data {
    var data1: [String]
    var data2: [String]
    var data3: [String]
}

class DataLoader{
    
    func loadDataByQueue() async -> [[String]] {
        printT("loadDataByQueue start", showThread: true)
        defer {
            printT("loadDataByQueue end")
        }
        let d1 = await loadData1()
        let d2 = await loadData2()
        let d3 = await loadData3()
        
        return [d1, d2, d3]
    }
    
    func loadDataBySeparate() async -> Data {
        printT("loadDataBySeparate start", showThread: true)
        defer {
            printT("loadDataBySeparate end")
        }
        async let d1 = loadData1()
        async let d2 = loadData2()
        async let d3 = loadData3()
        
        return await Data(data1: d1, data2: d2, data3: d3)
    }
    
    func loadData1() async -> [String] {
        let t = Task {
            printT("loadData1 start", showThread: true)
            defer {
                printT("loadData1 end")
            }
            try! await Task.sleep(nanoseconds: 1_000_000_000)
            
            return ["Data11", "Data12", "Data13"]
        }
        return await t.value
    }
    
    func loadData2() async -> [String] {
        let t = Task {
            printT("loadData2 start", showThread: true)
            defer {
                printT("loadData2 end")
            }
            try! await Task.sleep(nanoseconds: 2_000_000_000)
            
            return ["Data21", "Data22", "Data23"]
        }
        return await t.value
    }
    
    func loadData3() async -> [String] {
        let t = Task {
            printT("loadData3 start", showThread: true)
            defer {
                printT("loadData3 end")
            }
            try! await Task.sleep(nanoseconds: 1_000_000_000)
            
            return ["Data31", "Data32", "Data33"]
        }
        return await t.value
        
    }
    
}

func printT(_ text: String, showThread: Bool = false) {
    let th = "\(Thread.current) threadPriority \(Thread.threadPriority())  taskPriority \(Task.currentPriority)"
    print("\(text) \(showThread ? th : "")")
}

func asyncPrintT(_ text: String, showThread: Bool = false) async {
    try! await Task.sleep(nanoseconds: 1_000_000_000)
    printT(text, showThread: showThread)
}

/* example_2 result
 
 loadDataByQueue start <NSThread: 0x600001701fc0>{number = 6, name = (null)}
 loadData1 start <NSThread: 0x600001706900>{number = 2, name = (null)}
 loadData1 end
 loadData2 start <NSThread: 0x600001700540>{number = 7, name = (null)}
 loadData2 end
 loadData3 start <NSThread: 0x600001701fc0>{number = 6, name = (null)}
 loadData3 end
 loadDataByQueue end
 
 loadDataBySeparate start <NSThread: 0x60000171c180>{number = 6, name = (null)}
 loadData2 start <NSThread: 0x60000170ce80>{number = 4, name = (null)}
 loadData3 start <NSThread: 0x600001710140>{number = 9, name = (null)}
 loadData1 start <NSThread: 0x60000170afc0>{number = 2, name = (null)}
 loadData1 end
 loadData3 end
 loadData2 end
 loadDataBySeparate end
 
 Как видно Task это не значит отдельный поток
 Thread.sleep() vs Task.sleep()
 Let’s just look at the old and new sleep APIs:

 Thread.sleep() is the old API that blocks a thread for the given amount of seconds — it doesn’t load the CPU, the core just idles. Edit: Turns out the core doesn’t idle but DispatchQueue.concurrentPerform creates only as many threads as there are cores so even if the blocked treads don’t do anything it doesn’t create more threads to do more work during this time.

 Task.sleep() is the new async API that does “sleep”. It suspends the current Task instead of blocking the thread — that means the CPU core is free to do something else for the duration of the sleep.

 Or to put them side by side:

 Thread.sleep()                                 Task.sleep()
 Blocks the thread                              Suspends and lets other tasks run
 Slow switching of threads on same core         Quickly switching via function calls to a continuation
 Rigid, cannot be cancelled                     Can be cancelled while suspended
 Code resumes on the same thread                Could resume on another thread, threads don’t matter 
 
 */

func example_2() async{
    let dl = DataLoader()
//    await dl.loadDataByQueue()
    await dl.loadDataBySeparate()
}


//Task { @MainActor in
//    await example_2()
//}

/* Example 3 result 
 Operation 1 <NSThread: 0x600001709440>{number = 5, name = (null)} threadPriority 0.5  taskPriority TaskPriority.high
 Operation 2 <NSThread: 0x60000170e780>{number = 6, name = (null)} threadPriority 0.5  taskPriority TaskPriority.medium
 Operation 3 <NSThread: 0x600001709d40>{number = 4, name = (null)} threadPriority 0.5  taskPriority TaskPriority.high
 */

func example_3() async{
    await asyncPrintT("Operation 1", showThread: true)
    Task.detached {
        // Runs asynchronously
        await asyncPrintT("Operation 2", showThread: true)
    }
    await asyncPrintT("Operation 3", showThread: true)
}

Task {
    await example_3()
}



//: [Next](@next)



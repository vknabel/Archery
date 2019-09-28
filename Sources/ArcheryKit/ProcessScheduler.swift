import Foundation
#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin.C
#else
    func fflush(_: UnsafeMutablePointer<FILE>!) -> Int32 {
        return 0
    }
#endif

class ProcessScheduler {
    private static var lock = NSLock()
    static var scheduledProcesses: [ObjectIdentifier: Process] = [:]

    static func run(_ process: Process) throws {
        process.terminationHandler = { process in
            ProcessScheduler.remove(process)
        }
        if #available(OSX 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
    }

    private static func interrupt() {
        print("🏹  Abort all scripts")
        for task in scheduledProcesses.values {
            task.interrupt()
        }
        for task in scheduledProcesses.values {
            task.waitUntilExit()
        }
        fflush(stdout)
    }

    private static func add(_ process: Process) {
        lock.lock()
        prepare()
        scheduledProcesses[ObjectIdentifier(process)] = process
        lock.unlock()
    }

    private static func remove(_ task: Process) {
        lock.lock()
        scheduledProcesses[ObjectIdentifier(task)] = nil
        lock.unlock()
    }
}

extension ProcessScheduler {
    private static var hasBeenPrepared = false
    private static func prepare() {
        if hasBeenPrepared { return }

        signal(SIGINT) { _ in
            ProcessScheduler.interrupt()

            signal(SIGINT, SIG_DFL)
            raise(SIGINT)
        }

        hasBeenPrepared = true
    }
}

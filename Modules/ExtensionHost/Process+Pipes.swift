import Foundation

extension Process {
    struct StdioPipeSet: Hashable, Sendable {
        let stdin: Pipe
        let stdout: Pipe
        let stderr: Pipe

        init(stdin: Pipe, stdout: Pipe, stderr: Pipe) {
            self.stdin = stdin
            self.stdout = stdout
            self.stderr = stderr
        }

        init() {
            self.init(stdin: Pipe(), stdout: Pipe(), stderr: Pipe())
        }
    }

    var stdioPipeSet: StdioPipeSet? {
        get {
            guard
                let inPipe = standardInput as? Pipe,
                let outPipe = standardOutput as? Pipe,
                let errPipe = standardError as? Pipe
            else {
                return nil
            }

            return StdioPipeSet(stdin: inPipe, stdout: outPipe, stderr: errPipe)
        }
        set {
            standardInput = newValue?.stdin
            standardOutput = newValue?.stdout
            standardError = newValue?.stderr
        }
    }
}


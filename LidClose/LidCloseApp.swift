import ServiceManagement
import SwiftUI

@main
struct LidCloseApp: App {
    @State var isLogin: Bool = SMAppService.mainApp.status == .enabled

    var body: some Scene {
        let _ = NSApplication.shared.setActivationPolicy(.prohibited)

        Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { timer in
            if !lidClosed() {
                return
            }
            let _ = NSAppleScript(source: "tell app \"System Events\" to shut down")
            timer.invalidate()
        }

        return MenuBarExtra("", systemImage: isLogin ? "autostartstop" : "autostartstop.slash") {
            Button("Start at login: \(isLogin ? "On" : "Off")") {
                do {
                    if isLogin {
                        try SMAppService.mainApp.unregister()
                    } else {
                        try SMAppService.mainApp.register()
                    }
                    isLogin = SMAppService.mainApp.status == .enabled
                } catch {}
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func lidClosed() -> Bool {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", "ioreg -r -k AppleClamshellState -d 4 | grep AppleClamshellState  | head -1"]
        process.standardOutput = pipe
        let fileHandle = pipe.fileHandleForReading
        process.launch()
        if String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)?.contains("Yes") ?? false {
            return true
        }
        return false
    }
}

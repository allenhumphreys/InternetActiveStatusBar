import AppKit
import os.log

// Explicit main.swift is needed to remove the "Main Interface"
// Since a macOS application delegate is often created by a xib/storyboard
_ = autoreleasepool {
    os_log("main enter", log: .default)
    let application = NSApplication.shared
    let delegate = AppDelegate()
    application.delegate = delegate
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}

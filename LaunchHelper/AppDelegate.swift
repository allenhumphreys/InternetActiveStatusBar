import Cocoa
import os.log

// Sometimes there will be problems with the auto launch feature when there are a lot of different
// copies of the app floating around. Additionally, I think the apps need to be signed in order for
// SMLoginItemSetEnabled to work correctly.
//
// To reset the system, you can invoke (finder and stuff will take a little bit to recover):
// /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill
//
// To see a list of all version of the app that LaunchServices knows about, you can:
// /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump

// If you're having trouble with auto-launch, do the following
//
// 1. rm -rf ~/Library/Developer/Xcode/DerivedData/
// 2. /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump | grep Developer/Xcode/ | cut -d: -f2 | awk '{$1=$1};1' | awk '{ print "\""$0"\""}' | xargs /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {

        guard UserDefaults.group.shouldLaunchAtLogin else {
            os_log("Skipping launch because defaults say we should not launch", log: .default)
            terminate()
            return
        }

        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains { $0.bundleIdentifier == kMainAppID }

        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self,
                                                                selector: #selector(terminate),
                                                                name: .killLauncher,
                                                                object: nil)

            var url = Bundle.main.bundleURL

            url.deleteLastPathComponents(3)
            url.appendPathComponent("MacOS")
            url.appendPathComponent(kMainAppExecutableName)

            do {
                try NSWorkspace.shared.launchApplication(at: url, options: [], configuration: [:])
            } catch {
                os_log("Failed to launch the primary application at url: %{public}@", log: .default, url.path)
                os_log("Failed to launch the primary application due to error: %{public}@", log: .default, String(describing: error))
                terminate()
            }
        } else {
            os_log("Skipping launch because the main application is already running", log: .default)
            terminate()
        }
    }

    @objc func terminate() {
        NSApp.terminate(nil)
    }
}

extension URL {

    mutating func deleteLastPathComponents(_ count: Int) {
        for _ in 0..<count {
            deleteLastPathComponent()
        }
    }
}

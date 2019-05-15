import Foundation

// General configuration strings

let kLaunchHelperAppID = "com.demo.launchhelper"
let kMainAppID = "com.demo.internetactivestatusbar"
let kMainAppExecutableName = "InternetActiveStatusBar"

// For using distributed notification center

extension Notification.Name {
    static let killLauncher = Notification.Name("com.demo.killLauncher.notification")
}

// User defaults for sharing information betwen the 2 applications

extension UserDefaults {
    static let group = GroupUserDefaults(suiteName: "com.demo.appgroup")!
}

final class GroupUserDefaults: UserDefaults {

    fileprivate override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
    }

    var shouldLaunchAtLogin: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}

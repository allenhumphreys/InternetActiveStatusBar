import Cocoa
import ServiceManagement

let kItemWidth: CGFloat = 60

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let isLauncherRunning = NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == kLaunchHelperAppID }

        if isLauncherRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: nil)
        }

        SMLoginItemSetEnabled(kLaunchHelperAppID as CFString, UserDefaults.group.shouldLaunchAtLogin)

        createStatusBarItem()
    }

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func createStatusBarItem() {
        let menu = NSMenu(title: "Menu")
        menu.addItem(withTitle: "Launch at Login", action: #selector(changeAutoLaunch), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "About", action: #selector(displayAbout), keyEquivalent: "")
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "")
        menu.items.forEach { $0.target = self }
        menu.delegate = self
        menu.autoenablesItems = false

        let height = statusItem.button!.bounds.height
        let buttonImage = NSImage(size: NSSize(width: kItemWidth, height: height), flipped: true, drawingHandler: { rect in
            let thing = "✅"
            (thing as NSString).draw(at: .zero, withAttributes: [.font: NSFont.systemFont(ofSize: 14)])
            return true
        })

        statusItem.button?.appearance = NSAppearance(named: .darkAqua)
        statusItem.button?.image = buttonImage

        statusItem.menu = menu
        statusItem.length = kItemWidth
    }

    @objc
    func quit() {
        NSApp.terminate(self)
    }

    @objc
    func displayAbout() {
//        NSApp.activate(ignoringOtherApps: true)
//        aboutWindowController?.window?.makeKeyAndOrderFront(self)
    }

    @objc
    func changeAutoLaunch(menuItem: NSMenuItem) {
        let newValue = menuItem.state == .off

        UserDefaults.group.shouldLaunchAtLogin = newValue
        SMLoginItemSetEnabled(kLaunchHelperAppID as CFString, newValue)
    }
}

extension AppDelegate: NSMenuDelegate {

    func numberOfItems(in menu: NSMenu) -> Int {
        return menu.items.count
    }

    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        switch index {
        case 0:
            item.state = UserDefaults.group.shouldLaunchAtLogin ? .on : .off
        default: ()
        }

        return true
    }
}

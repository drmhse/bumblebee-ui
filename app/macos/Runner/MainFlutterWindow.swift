import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 1280, height: 820)
    self.minSize = NSSize(width: 1100, height: 720)
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)
    self.isMovableByWindowBackground = true

    RegisterGeneratedPlugins(registry: flutterViewController)
    let windowChromeChannel = FlutterMethodChannel(
      name: "bumblebee/window_chrome",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    windowChromeChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "performTitlebarDoubleClick":
        self?.performTitlebarDoubleClick()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  private func performTitlebarDoubleClick() {
    let action = UserDefaults.standard
      .persistentDomain(forName: UserDefaults.globalDomain)?["AppleActionOnDoubleClick"] as? String

    switch action?.lowercased() {
    case "minimize":
      self.miniaturize(nil)
    case "none":
      return
    default:
      self.zoom(nil)
    }
  }
}

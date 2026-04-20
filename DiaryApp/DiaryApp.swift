import SwiftUI
import CoreData
import CloudKit

@main
struct DiaryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userIdentifier") private var userIdentifier: String = ""
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environment(\.theme, AppTheme.default)
                } else {
                    LoginView()
                        .environment(\.theme, AppTheme.default)
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}

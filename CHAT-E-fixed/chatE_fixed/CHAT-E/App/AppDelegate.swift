import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize window for iOS 12 compatibility
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create and configure the root view controller
        let chatViewController = ChatViewController()
        let navigationController = UINavigationController(rootViewController: chatViewController)
        
        // Configure navigation bar appearance
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // iOS 12 compatible navigation bar styling
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.barTintColor = .white
            navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        }
        navigationController.navigationBar.tintColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
        
        // Set root view controller
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - UISession Lifecycle (iOS 13+)
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
import SwiftUI
import SwiftData
import UIKit

enum AppOrientationLock {
    nonisolated(unsafe) static var current: UIInterfaceOrientationMask = .portrait
}

@MainActor
enum AppOrientationController {
    static func apply(_ mask: UIInterfaceOrientationMask) {
        AppOrientationLock.current = mask

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
            print("Failed to update orientation: \(error.localizedDescription)")
        }
        scene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        UIViewController.attemptRotationToDeviceOrientation()
    }

    static func reset() {
        apply(.portrait)
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        AppOrientationLock.current
    }
}

@main
struct DailyTodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState = AppStateManager()

    let container: ModelContainer = {
        let schema = Schema([
            CountdownEvent.self,
            TodoItem.self,
            TodoReminder.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Migration failed — recreate store
            print("SwiftData migration failed: \(error). Recreating store.")
            let freshConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            // Allow Xcode to rebuild the store from scratch
            guard let container = try? ModelContainer(for: schema, configurations: [freshConfig]) else {
                fatalError("无法初始化 ModelContainer")
            }
            return container
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .modelContainer(container)
                .onAppear {
                    Task {
                        await NotificationService.shared.requestAuthorization()
                    }
                }
        }
    }
}

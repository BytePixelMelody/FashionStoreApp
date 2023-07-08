//
//  SceneDelegate.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.02.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var router: RouterProtocol?
    private let coreDataService: CoreDataServiceProtocol = CoreDataService()
    private let cacheService: CacheServiceProtocol = CacheService()
    private lazy var webService: WebServiceProtocol = WebService(cacheService: cacheService)
    private let deepLinkService: DeepLinkServiceProtocol = DeepLinkService()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let rootNavigationController = UINavigationController()
        rootNavigationController.navigationBar.isHidden = true
 
        let moduleBuilder = ModuleBuilder(coreDataService: coreDataService, webService: webService)
        router = Router(navigationController: rootNavigationController, moduleBuilder: moduleBuilder)
        // errors handler singleton
        Errors.handler.router = router
        router?.showStoreScreen()
        
        // processing deep link if App was closed
        // if product id found - show product screen
        if let productId = deepLinkService.fetchProductId(url: connectionOptions.urlContexts.first?.url) {
            switchToProduct(productId: productId)
        }
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
        self.window = window
    }
    
    // processing deep link if App was opened 
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // if product id found - show product screen
        if let productId = deepLinkService.fetchProductId(url: URLContexts.first?.url) {
            switchToProduct(productId: productId)
        }
    }
    
    private func switchToProduct(productId: String) {
        Task {
            do {
                let catalog: Catalog = try await webService.getData(urlString: Settings.catalogUrl)
                guard
                    let products = catalog.audiences.first?.categories.first?.products,
                    let product = products.first(where: { $0.id == UUID(uuidString: productId) }) else {
                    return
                }
                // dismiss modal screen if presented
                router?.dismissScreen()
                router?.showProductScreenInstantly(product: product, image: nil)
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}


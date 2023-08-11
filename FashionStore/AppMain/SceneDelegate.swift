//
//  SceneDelegate.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.02.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var router: Routing?
    private let coreDataService: CoreDataServiceProtocol = CoreDataService()
    private let cacheService: CacheServiceProtocol = CacheService()
    private lazy var webService: WebServiceProtocol = WebService(cacheService: cacheService)
    private let deepLinkService: DeepLinkServiceProtocol = DeepLinkService()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let rootNavigationController = UINavigationController()
        rootNavigationController.navigationBar.isHidden = true

        let moduleBuilder = ModuleBuilder(coreDataService: coreDataService, webService: webService)
        router = Router(navigationController: rootNavigationController, moduleBuilder: moduleBuilder)
        // errors handler singleton
        Errors.handler.router = router
        router?.showStoreScreen()

        // processing deep link if App was closed
        // if product id found - show product screen
        if let productID = deepLinkService.fetchProductID(url: connectionOptions.urlContexts.first?.url) {
            switchToProduct(productID: productID)
        }

        window?.rootViewController = rootNavigationController
        window?.makeKeyAndVisible()
    }

    // processing deep link if App was opened 
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // if product id found - show product screen
        if let productID = deepLinkService.fetchProductID(url: URLContexts.first?.url) {
            switchToProduct(productID: productID)
        }
    }

    private func switchToProduct(productID: String) {
        Task {
            do {
                let catalog: Catalog = try await webService.getData(urlString: Settings.catalogURL)
                guard
                    let products = catalog.audiences.first?.categories.first?.products,
                    let product = products.first(where: { $0.id == UUID(uuidString: productID) }) else {
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

}

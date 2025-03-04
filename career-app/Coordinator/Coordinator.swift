//
//  Coordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import UIKit

public protocol Coordinator: CoordinatorDelegate {
    var delegate: CoordinatorDelegate? { get set }
    var childCoordinator: Coordinator? { get set }
    var viewController: UIViewController! { get set }
    var navigationController: UINavigationController? { get set }
    var modulePath: String? { get }
    
    func start(usingPresenter presenter: CoordinatorPresenter, animated: Bool)
}

extension Coordinator {
    
    public var modulePath: String? { nil }
    
    public func start(usingPresenter presenter: CoordinatorPresenter, animated: Bool = false) {
        performStart(usingPresenter: presenter, animated: animated)
    }
    
    public func performStart(usingPresenter presenter: CoordinatorPresenter, animated: Bool) {
        guard viewController != nil else {
            assertionFailure("view controller is null when pushing")
            return
        }
        navigationController = presenter.present(destiny: viewController, animated: animated)
    }
    
    public func route(to coordinator: Coordinator,
                      withPresenter presenter: CoordinatorPresenter,
                      animated: Bool = true,
                      delegate: CoordinatorDelegate? = nil) {
        childCoordinator = coordinator
        coordinator.delegate = delegate ?? self
        coordinator.start(usingPresenter: presenter, animated: animated)
    }
}

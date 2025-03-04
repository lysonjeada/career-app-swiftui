//
//  CoordinatorPresenter.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import Foundation
import UIKit

public protocol CoordinatorPresenterProtocol {
    var rootViewController: UIViewController { get }
    func present(destiny destinyViewController: UIViewController, animated: Bool) -> UINavigationController
}

public enum CoordinatorPresenter: CoordinatorPresenterProtocol {
    case push(UINavigationController)
    case present(UIViewController, UIModalPresentationStyle = .fullScreen, closeButton: Bool = false)
}

extension CoordinatorPresenter {
    public var rootViewController: UIViewController {
        switch self {
        case .push(let navigationController):
            return navigationController
        case .present(let viewController, _, _):
            return viewController
        }
    }
    
    public func present(destiny destinyViewController: UIViewController, animated: Bool) -> UINavigationController {
        switch self {
        case .push(let navigationController):
            return pushStart(navigationController: navigationController,
                             destiny: destinyViewController,
                             animated: animated)
        case .present(let viewController, let style, let closeButton):
            return presentStart(viewController: viewController,
                                style: style,
                                destiny: destinyViewController,
                                animated: animated,
                                closeButton: closeButton)
        }
    }
}

private extension CoordinatorPresenter {
    func pushStart(navigationController: UINavigationController,
                   destiny destinyViewController: UIViewController,
                   animated: Bool) -> UINavigationController {
        navigationController.pushViewController(destinyViewController, animated: animated)
        return navigationController
    }
    
    func presentStart(viewController: UIViewController,
                      style: UIModalPresentationStyle,
                      destiny destinyViewController: UIViewController,
                      animated: Bool,
                      closeButton: Bool) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = style
        viewController.present(navigationController, animated: animated, completion: nil)
        return navigationController
    }
}

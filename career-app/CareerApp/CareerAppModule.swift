//
//  CareerAppModule.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import UIKit
import SwiftUI

//protocol FlowDelegate {
//    func coordinator(for location: FlowLocation) -> Coordinator?
//}
//
//public protocol CoordinatorDelegate: AnyObject {
//    func didFinish(_ coordinator: Coordinator)
//}
//
//extension CoordinatorDelegate {
//    func didFinish(_ coordinator: Coordinator) {}
//}
//
//public class CareerAppModule {
//    private enum Paths: String, CaseIterable {
//        case home = "home"
//    }
//    
//    public init() {}
//}
//
//extension CareerAppModule {
//    private func getHomeCoordinator() -> Coordinator {
//        let coordinator = HomeCoordinator()
//        coordinator.navigationController = UINavigationController(rootViewController: UIHostingController(rootView: LoginView()))
//        return HomeCoordinator()
//    }
//    
//   func coordinator(for location: FlowLocation) -> Coordinator? {
//        let paths = Paths(rawValue: location.path)
//        switch paths {
//        case .home:
//            return getHomeCoordinator()
//        case .none:
//            return nil
//        }
//    }
//}
//
//public class FlowLocation {
//    public let path: String
//    
//    public init(path: String) {
//        self.path = path
//    }
//}

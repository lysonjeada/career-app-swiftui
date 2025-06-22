//
//  InterviewQuestionsViewController.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 24/10/24.
//

import UIKit
import SwiftUI

final public class InterviewQuestionsViewController: UIViewController {
    private lazy var mainView: UIView = {
        let view = InterviewQuestionsView()
        let controller = UIHostingController(rootView: view)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller.view
    }()

    public override func loadView() {
        self.view = UIView()
        view.backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
    }

    func setupHierarchy() {
        view.addSubview(mainView)
    }

    func setupConstraints() {
        guard let superview = self.mainView.superview else { return }

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
            mainView.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
            mainView.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor)
        ])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.frame = view.bounds
    }
}

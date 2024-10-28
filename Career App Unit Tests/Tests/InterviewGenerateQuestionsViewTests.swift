//
//  Untitled.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 24/10/24.
//

import _TestingInternals
import SnapshotTesting
import SwiftUI
import XCTest

@testable import career_app

final class InterviewGenerateQuestionsViewTests: XCTestCase {
    
    
    func testInterviewGenerateQuestionsView() {
        //        let questionsView = InterviewQuestionsView(questions: [
        //            "What is your experience with iOS development?",
        //            "How comfortable are you with Swift and Objective-C?",
        //            "Can you describe a challenge you faced in your previous project and how you resolved it?"
        //        ])
        //        let view: UIView = UIHostingController(rootView: questionsView).view
                let questionsView = InterviewQuestionsView(questions: [])
                
                
                assertSnapshot(matching: questionsView, as: .image(layout: .device(config: .iPhone13)))
         
    }
}

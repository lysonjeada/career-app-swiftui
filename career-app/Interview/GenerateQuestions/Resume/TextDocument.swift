//
//  TextDocument.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 25/08/24.
//

import SwiftUI

//struct TextDocument: FileDocument {
//    static var readableContentTypes: [UTType] {
//        [.plainText]
//    }
//    
//    var text = ""
//    
//    init(text: String) {
//        self.text = text
//    }
//    
//    init(configuration: ReadConfiguration) throws {
//        if let data = configuration.file.regularFileContents {
//            text = String(decoding: data, as: UTF8.self)
//        } else {
//            text = ""
//        }
//    }
//    
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        FileWrapper(regularFileWithContents: Data(text.utf8))
//    }
//}

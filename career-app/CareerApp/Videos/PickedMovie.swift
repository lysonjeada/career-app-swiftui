//
//  PickedMovie.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct PickedMovie:
    Transferable {

    let url: URL

    static var transferRepresentation:
        some TransferRepresentation {

        FileRepresentation(
            contentType: .movie
        ) { movie in

            SentTransferredFile(
                movie.url
            )

        } importing: {
            received in

            let destination =
                FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent(
                        UUID().uuidString
                    )
                    .appendingPathExtension(
                        received.file
                            .pathExtension
                    )

            try FileManager.default
                .copyItem(
                    at:
                        received.file,
                    to:
                        destination
                )

            return PickedMovie(
                url:
                    destination
            )
        }
    }
}

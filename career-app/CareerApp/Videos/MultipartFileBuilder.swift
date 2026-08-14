//
//  MultipartFileBuilder.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import Foundation

enum MultipartFileBuilder {
    static func build(
        title: String,
        description: String,
        videoURL: URL
    ) throws -> (
        fileURL: URL,
        boundary: String
    ) {
        let boundary =
            "Boundary-\(UUID().uuidString)"

        let temporaryURL =
            FileManager.default
                .temporaryDirectory
                .appendingPathComponent(
                    UUID().uuidString
                )

        FileManager.default.createFile(
            atPath:
                temporaryURL.path,
            contents: nil
        )

        let output =
            try FileHandle(
                forWritingTo:
                    temporaryURL
            )

        defer {
            try? output.close()
        }

        func write(
            _ string: String
        ) throws {
            guard let data =
                    string.data(
                        using: .utf8
                    )
            else {
                return
            }

            try output.write(
                contentsOf: data
            )
        }

        try write(
            """
            --\(boundary)\r
            Content-Disposition: form-data; name="title"\r
            \r
            \(title)\r

            """
        )

        try write(
            """
            --\(boundary)\r
            Content-Disposition: form-data; name="description"\r
            \r
            \(description)\r

            """
        )

        let fileName =
            videoURL.lastPathComponent

        try write(
            """
            --\(boundary)\r
            Content-Disposition: form-data; name="file"; filename="\(fileName)"\r
            Content-Type: video/mp4\r
            \r

            """
        )

        let input =
            try FileHandle(
                forReadingFrom:
                    videoURL
            )

        defer {
            try? input.close()
        }

        while true {
            let chunk =
                try input.read(
                    upToCount:
                        1_048_576
                )

            guard let chunk,
                  !chunk.isEmpty
            else {
                break
            }

            try output.write(
                contentsOf: chunk
            )
        }

        try write(
            """
            \r
            --\(boundary)--\r

            """
        )

        return (
            temporaryURL,
            boundary
        )
    }
}

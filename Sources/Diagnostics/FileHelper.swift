//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FileHelper.swift
//
//  Created by Nacho Soto on 6/16/23.

import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
actor FileHandler {

    private let fileHandle: FileHandle

    let url: URL

    init(_ fileURL: URL) throws {
        try Self.createFileIfNecessary(fileURL)

        self.url = fileURL

        // TODO: verbose logs
        do {
            self.fileHandle = try FileHandle(forUpdating: fileURL)
        } catch {
            throw Error.failedCreatingHandle(error)
        }
    }

    deinit {
        // TODO: log errors and verbose close
        try? self.fileHandle.close()
    }

    /// - Note: this loads the entire file in memory
    /// For newer versions, consider using `readLines` instead.
    func readFile() throws -> Data {
        try self.moveToBeginningOfFile()

        return self.fileHandle.availableData
    }

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
    func readLines() throws -> AsyncLineSequence<FileHandle.AsyncBytes> {
        try self.moveToBeginningOfFile()

        return self.fileHandle.bytes.lines
    }

    func append(line: String) {
        self.fileHandle.seekToEndOfFile()
        self.fileHandle.write(line.asData)
        self.fileHandle.write(Self.lineBreak)
    }

//    func removeFirstLines(count: Int) {
//        precondition(count > 0, "Invalid count: \(count)")
//
//        let data = try self.readFile()
//
//        if let content = String(data: data, encoding: .utf8) {
//            var lines = content.components(separatedBy: "\n")
//            if n <= lines.count {
//                lines.removeFirst(n)
//                let remainingContent = lines.joined(separator: "\n")
//                if let remainingData = remainingContent.data(using: .utf8) {
//                    // Truncate the file
//                    fileHandle.truncateFile(atOffset: 0)
//                    // Write the remaining data back to the file
//                    fileHandle.write(remainingData)
//                    fileHandle.seek(toFileOffset: 0) // Reset the file pointer to the beginning
//                }
//            } else {
//                throw NSError(domain: "FileActor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Attempting to remove more lines than the file has."])
//            }
//        } else {
//            throw NSError(domain: "FileActor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert file data to string"])
//        }
//    }

    // TODO: remove N lines

    private static let lineBreak: Data = "\n".asData

}

// MARK: - Errors

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
extension FileHandler {

    enum Error: Swift.Error {

        case failedCreatingFile(URL)
        case failedCreatingDirectory(URL)
        case failedCreatingHandle(Swift.Error)
        case failedSeeking(Swift.Error)

    }

}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
private extension FileHandler {

    func moveToBeginningOfFile() throws {
        do {
            try self.fileHandle.seek(toOffset: 0)
        } catch {
            throw Error.failedSeeking(error)
        }
    }

    static func createFileIfNecessary(_ url: URL) throws {
        let fileManager: FileManager = .default

        guard !fileManager.fileExists(atPath: url.path) else { return }

        let directoryURL = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                // TODO: log
                try fileManager.createDirectory(at: directoryURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                throw Error.failedCreatingDirectory(directoryURL)
            }
        }

        // TODO: log
        if !fileManager.createFile(atPath: url.path, contents: nil, attributes: nil) {
            throw Error.failedCreatingFile(url)
        }
    }

}

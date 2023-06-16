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

    func readFile() throws -> Data {
        // TODO: fileHandle.bytes?

        // TODO: wrap error
        try self.fileHandle.seek(toOffset: 0)

        return self.fileHandle.availableData
    }

    func append(line: String) {
        self.fileHandle.seekToEndOfFile()
        self.fileHandle.write(line.asData)
        self.fileHandle.write(Self.lineBreak)
    }

    private static let lineBreak: Data = "\n".asData

}

// MARK: - Errors

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
extension FileHandler {

    enum Error: Swift.Error {

        case failedCreatingFile(URL)
        case failedCreatingDirectory(URL)
        case failedCreatingHandle(Swift.Error)

    }

}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
private extension FileHandler {

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


//class FileHelper {
//
//    let fileManager = FileManager.default
//    let directoryURL: URL
//
//    init(directoryURL: URL) {
//        self.directoryURL = directoryURL
//    }
//
//    private let test: Test = .init()
//
//    func append(content: String, to filePath: String) throws {
//        let fileURL = self.directoryURL.appendingPathComponent(filePath)
//        let data = content.asData
//
//        if self.fileManager.fileExists(atPath: fileURL.path) {
//            do {
//                let fileHandle = try FileHandle(forWritingTo: fileURL)
//                fileHandle.seekToEndOfFile()
//                fileHandle.write(data)
//                fileHandle.closeFile()
//            } catch {
//                throw Error.unableToCreateFileHandle(error)
//            }
//        } else {
//            try? data.write(to: fileURL)
//        }
//    }
//
//    func deleteFile(filePath: String) -> Bool {
//        let fileURL = directoryURL.appendingPathComponent(filePath)
//        do {
//            try fileManager.removeItem(at: fileURL)
//            return true
//        } catch {
//            print("Error deleting file: \(error)")
//            return false
//        }
//    }
//
//    func readFilePerLines(filePath: String) -> [String] {
//        let fileURL = directoryURL.appendingPathComponent(filePath)
//        var readLines = [String]()
//        if let reader = try? LineReader(path: fileURL.path) {
//            for line in reader {
//                readLines.append(line)
//            }
//        }
//        return readLines
//    }
//
//    func removeFirstLinesFromFile(filePath: String, numberOfLinesToRemove: Int) {
//        let readLines = readFilePerLines(filePath: filePath)
//        _ = deleteFile(filePath: filePath)
//        let textToAppend: String
//        if readLines.isEmpty || numberOfLinesToRemove >= readLines.count {
//            print("Trying to remove \(numberOfLinesToRemove) from file with \(readLines.count) lines.")
//            textToAppend = ""
//        } else {
//            let linesAfterRemoval = Array(readLines[numberOfLinesToRemove...])
//            textToAppend = linesAfterRemoval.joined(separator: "\n")
//        }
//        appendToFile(filePath: filePath, contentToAppend: textToAppend)
//    }
//
//    func fileIsEmpty(filePath: String) -> Bool {
//        let fileURL = directoryURL.appendingPathComponent(filePath)
//        if !fileManager.fileExists(atPath: fileURL.path) || (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) == 0 {
//            return true
//        }
//        return false
//    }
//
//}

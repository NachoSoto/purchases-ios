//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  FileHandlerTests.swift
//
//  Created by Nacho Soto on 6/16/23.

import Foundation
import Nimble
@testable import RevenueCat
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
class FileHandlerTests: TestCase {

    private var handler: FileHandler!

    override func setUp() async throws {
        try await super.setUp()

        try AvailabilityChecks.iOS13APIAvailableOrSkipTest()

        self.handler = try Self.createWithTemporaryFile()
    }

    override func tearDown() async throws {
        self.handler = nil

        try await super.tearDown()
    }

    func testReadingEmptyFile() async throws {
        let data = try await self.handler.readFile()
        expect(data).to(beEmpty())
    }

    func testAppendOneLine() async throws {
        let content = UUID().uuidString

        await self.handler.append(line: content)

        let data = try await self.handler.readFile()
        expect(data).to(matchLines(content))
    }

    func testAppendMultipleLines() async throws {
        let line1 = UUID().uuidString
        let line2 = UUID().uuidString

        await self.handler.append(line: line1)
        await self.handler.append(line: line2)

        let data = try await self.handler.readFile()
        expect(data).to(matchLines(line1, line2))
    }

    func testAppendsToExistingContent() async throws {
        let line1 = UUID().uuidString
        let line2 = UUID().uuidString

        await self.handler.append(line: line1)

        // Re-create handler
        self.handler = try .init(await self.handler.url)

        let data = try await self.handler.readFile()
        expect(data).to(matchLines(line1, line2))
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
private extension FileHandlerTests {

    static func temporaryFileURL() -> URL {
        return FileManager.default
            .temporaryDirectory
            .appendingPathComponent("file_handler_tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: false)
            .appendingPathExtension("json")
    }

    static func createWithTemporaryFile() throws -> FileHandler {
        return try .init(Self.temporaryFileURL())
    }

}

private func matchLines(_ lines: String...) -> Nimble.Predicate<Data> {
    return matchData(
        (lines + [""]) // For trailing line break
            .joined(separator: "\n")
            .asData
    )
}

private func matchData(_ expectedValue: Data) -> Nimble.Predicate<Data> {
    return Predicate.define { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }

        return PredicateResult(
            bool: expectedValue == actualValue,
            message: .expectedCustomValueTo(
                "equal '\(expectedValue.asUTF8String)'",
                actual: "'\(actualValue.asUTF8String)'"
            )
        )
    }
}

private extension Data {

    var asUTF8String: String {
        return .init(data: self, encoding: .utf8)!
    }

}

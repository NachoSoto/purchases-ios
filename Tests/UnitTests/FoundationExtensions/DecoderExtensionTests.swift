//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  DecoderExtensionTests.swift
//
//  Created by Nacho Soto on 4/26/22.

import Nimble
import XCTest

@testable import RevenueCat

// swiftlint:disable type_name identifier_name nesting

class DecoderExtensionsDefaultValueTests: XCTestCase {

    private struct Data: Codable, Equatable {
        enum E: String, DefaultValueProvider, Codable, Equatable {
            case e1
            case e2

            static let defaultValue: Self = .e2
        }

        @DefaultValue<E> var e: E

        init(e: E) {
            self.e = e
        }
    }

    func testDecodesActualValue() throws {
        let data = Data(e: .e1)
        let decodedData = try data.encodeAndDecode()

        expect(decodedData) == data
    }

    func testDecodesDefaultValue() throws {
        expect(try Data.decodeEmptyData().e) == Data.E.defaultValue
    }

    func testDecodesDefaultValueForInvalidValue() throws {
        let json = "{\"e\": \"e3\"}".data(using: .utf8)!
        let data: Data = try JSONDecoder.default.decode(jsonData: json)

        expect(data.e) == Data.E.defaultValue
    }

}

class DecoderExtensionsIgnoreErrorsTests: XCTestCase {

    private struct Data: Codable, Equatable {
        @IgnoreDecodeErrors<URL?> var url: URL?

        init(url: URL) {
            self.url = url
        }
    }

    func testDecodesActualValue() throws {
        let data = Data(url: URL(string: "https://revenuecat.com")!)
        let decodedData = try data.encodeAndDecode()

        expect(decodedData) == data
    }

    func testIgnoresErrors() throws {
        let json = "{\"url\": \"not a! valid url@\"}".data(using: .utf8)!
        let data: Data = try JSONDecoder.default.decode(jsonData: json)

        expect(data.url).to(beNil())
    }

}

class DecoderExtensionsIgnoreCollectionErrorsTests: XCTestCase {

    private struct Data: Codable, Equatable {
        struct Content: Codable, Equatable {
            let string: String
        }

        @IgnoreDecodeErrors<[Int]> var list: [Int]
        @IgnoreDecodeErrors<[String: Content]> var map1: [String: Content]
        @IgnoreDecodeErrors<[Int: [Content]]> var map2: [Int: [Content]]

        init(list: [Int], map1: [String: Content], map2: [Int: [Content]]) {
            self.list = list
            self.map1 = map1
            self.map2 = map2
        }
    }

    func testDecodesActualValues() throws {
        let data = Data(list: [1, 2, 3],
                        map1: ["1": .init(string: "test1"), "2": .init(string: "test2")],
                        map2: [1: [.init(string: "a"), .init(string: "b")]])
        let decodedData = try data.encodeAndDecode()

        expect(decodedData) == data
    }

    func testIgnoresListErrors() throws {
        let json = "{\"list\": [\"not a number\"]}".data(using: .utf8)!
        let data: Data = try JSONDecoder.default.decode(jsonData: json)

        expect(data.list) == []
    }

    func testIgnoresMapErrors() throws {
        let json = "{\"map1\": \"not a dictionary\"}".data(using: .utf8)!
        let data: Data = try JSONDecoder.default.decode(jsonData: json)

        expect(data.map1) == [:]
    }

    func testIgnoresInvalidKeyErrors() throws {
        let json = "{\"map2\": {\"not a number\": {}}}".data(using: .utf8)!
        let data: Data = try JSONDecoder.default.decode(jsonData: json)

        expect(data.map1) == [:]
    }

    func testIgnoresNestedErrors() throws {
        let json = "{\"map2\": {1: [{\"string\": [\"an array instead\"]}]}}".data(using: .utf8)!
        let data: Data = try JSONDecoder.default.decode(jsonData: json)

        expect(data.map2) == [:]
    }

}

class DecoderExtensionsDefaultDecodableTests: XCTestCase {

    private struct Data: Codable, Equatable {
        @DefaultDecodable.True var bool1: Bool
        @DefaultDecodable.False var bool2: Bool
        @DefaultDecodable.EmptyString var string: String
        @DefaultDecodable.EmptyList var list: [String]
        @DefaultDecodable.EmptyMap var map: [String: Int]

        init(
            bool1: Bool,
            bool2: Bool,
            string: String,
            list: [String],
            map: [String: Int]
        ) {
            self.bool1 = bool1
            self.bool2 = bool2
            self.string = string
            self.list = list
            self.map = map
        }
    }

    func testDecodesActualValues() throws {
        let data = Data(bool1: false, bool2: true, string: "test", list: ["a", "b"], map: ["a": 1])
        let decodedData = try data.encodeAndDecode()

        expect(decodedData) == data
    }

    func testDecodesDefaultTrue() throws {
        expect(try Data.decodeEmptyData().bool1) == true
    }

    func testDecodesDefaultFalse() throws {
        expect(try Data.decodeEmptyData().bool2) == false
    }

    func testDecodesDefaultString() throws {
        expect(try Data.decodeEmptyData().string) == ""
    }

    func testDecodesDefaultList() throws {
        expect(try Data.decodeEmptyData().list) == []
    }

    func testDecodesDefaultMap() throws {
        expect(try Data.decodeEmptyData().map) == [:]
    }

}

private extension Decodable where Self: Encodable {

    func encodeAndDecode() throws -> Self {
        return try JSONDecoder.default.decode(
            jsonData: JSONEncoder.default.encode(self)
        )
    }

}

private extension Decodable {

    static func decodeEmptyData() throws -> Self {
        let json = "{}".data(using: .utf8)!
        return try JSONDecoder.default.decode(jsonData: json)
    }

}

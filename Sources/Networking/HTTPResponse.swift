//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  HTTPResponse.swift
//
//  Created by César de la Vega on 4/19/21.
//

import Foundation

struct HTTPResponse {

    typealias Body = [String: Any]

    let statusCode: HTTPStatusCode
    let jsonObject: Body

}

extension HTTPResponse: CustomStringConvertible {

    var description: String {
//        if let bodyDescription = (self.body as? CustomStringConvertible)?.description {
        return "HTTPResponse(statusCode: \(self.statusCode.rawValue), body: \(self.jsonObject.description))"
//        } else {
//            return "HTTPResponse(statusCode: \(self.statusCode.rawValue), body: \(type(of: self.body))"
//        }
    }

}

// MARK: -

///// The content of an `HTTPResponse`
///// - Note: this can be removed in favor of `Decodable` when all responses implement `Decodable`.
// protocol HTTPResponseBody {
//
//    static func create(with data: Data) throws -> Self
//
// }

/// Default implementation of `HTTPResponseBody` for any `Decodable`
// extension Decodable {
//
//    static func create(with data: Data) throws -> Self {
//        return try defaultJsonDecoder.decode(jsonData: data)
//    }
//
// }

// MARK: -

/// The response content of a failed request.
struct ErrorResponse {

    let code: BackendErrorCode
    let message: String?
    let attributeErrors: [String: String]

}

extension ErrorResponse {

    /// Converts this `ErrorResponse` into an `ErrorCode` backed by the corresponding `BackendErrorCode`.
    func asBackendError(withStatusCode statusCode: HTTPStatusCode) -> Error {
        return ErrorUtils.backendError(
            withBackendCode: self.code,
            backendMessage: self.message,
            extraUserInfo: [
                ErrorDetails.finishableKey: !statusCode.isServerError,
                Backend.RCSuccessfullySyncedKey: statusCode.isSuccessfullySynced,
                Backend.RCAttributeErrorsKey as NSError.UserInfoKey: self.attributeErrors
            ]
        )
    }

}

extension ErrorResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case attributeErrors
    }

    private struct AttributeError: Decodable {
        let keyName: String
        let message: String
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let codeAsInteger = try? container.decodeIfPresent(Int.self, forKey: .code)
        let codeAsString = try? container.decodeIfPresent(String.self, forKey: .code)

        self.code = BackendErrorCode(code: codeAsInteger ?? codeAsString)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)

        let attributeErrors = try container.decodeIfPresent(Array<AttributeError>.self,
                                                            forKey: .attributeErrors) ?? []

        self.attributeErrors = attributeErrors
            .dictionaryAllowingDuplicateKeys { $0.keyName }
            .mapValues { $0.message }
    }

}

extension ErrorResponse {

    static func from(response: HTTPResponse.Body) -> Self {
        do {
            return try defaultJsonDecoder.decode(dictionary: response)
        } catch {
            Logger.error(Strings.codable.decoding_error(error))

            return .init(code: .unknownError,
                         message: nil,
                         attributeErrors: [:])
        }
    }

}

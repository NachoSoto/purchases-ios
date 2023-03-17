//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  ProductsEntitlementsResponse.swift
//
//  Created by Nacho Soto on 3/17/23.

import Foundation

struct ProductsEntitlementsResponse {

    var products: [Product]

}

extension ProductsEntitlementsResponse {

    struct Product {

        var identifier: String
        var entitlements: [String]

    }

}

// MARK: - Codable

extension ProductsEntitlementsResponse.Product: Codable {

    private enum CodingKeys: String, CodingKey {

        case identifier = "id"
        case entitlements

    }

}

extension ProductsEntitlementsResponse: Codable {}
extension ProductsEntitlementsResponse: HTTPResponseBody {}

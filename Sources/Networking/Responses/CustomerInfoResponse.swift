//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  CustomerInfoResponse.swift
//
//  Created by Nacho Soto on 4/12/22.

import Foundation

struct CustomerInfoResponse {

    var requestDate: Date
    var subscriber: Subscriber

}

extension CustomerInfoResponse {

    struct Subscriber {

//        let subscriptionTransactionsByProductId: [String: [String: Any]]
        let originalAppUserId: String
        let managementUrl: URL?
        let originalApplicationVersion: String?
        let originalPurchaseDate: Date?
        let firstSeen: Date
//        let nonSubscriptionsByProductId: [String: [[String: Any]]]
//        let entitlementsData: [String: Any]
//        let nonSubscriptionTransactions: [StoreTransaction] BackendParsedTransaction
//        let allTransactionsByProductId: [String: [String: Any]]
//        let allPurchases: [String: [String: Any]]
    }
}

extension CustomerInfoResponse.Subscriber: Decodable {}
extension CustomerInfoResponse: Decodable {}

extension CustomerInfoResponse: HTTPResponseBody {}

// TODO: equality with no date

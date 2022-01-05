//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  TransactionsFactory.swift
//
//  Created by RevenueCat.
//

import Foundation

enum TransactionsFactory {

    static func nonSubscriptionTransactions(withSubscriptionsData subscriptionsData: [String: [[String: Any]]],
                                            dateFormatter: DateFormatterType) -> [StoreTransaction] {
        subscriptionsData
            .flatMap { (productId: String, transactionData: [[String: Any]]) -> [StoreTransaction] in
                transactionData
                    .map { SimpleTransaction(with: $0, productID: productId, dateFormatter: dateFormatter) }
                    .compactMap { $0 }
                    .map { StoreTransaction($0) }
            }
            .sorted { $0.purchaseDate < $1.purchaseDate }
    }

}

/// `StoreTransactionType` backed by data parsed from the server
private struct SimpleTransaction: StoreTransactionType {

    let productIdentifier: String
    let purchaseDate: Date
    let transactionIdentifier: String

    init?(with serverResponse: [String: Any], productID: String, dateFormatter: DateFormatterType) {
        guard let revenueCatId = serverResponse["id"] as? String,
              let dateString = serverResponse["purchase_date"] as? String,
              let purchaseDate = dateFormatter.date(from: dateString) else {

                  // todo: extract string
                  Logger.error("Couldn't initialize Transaction from dictionary. " +
                               "Reason: unexpected format. Dictionary: \(serverResponse).")
                  return nil
              }

        self.transactionIdentifier = revenueCatId
        self.purchaseDate = purchaseDate
        self.productIdentifier = productID
    }

}

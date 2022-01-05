//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  SK1StoreTransaction.swift
//
//  Created by Nacho Soto on 1/4/22.

import StoreKit

internal struct SK1StoreTransaction: StoreTransactionType {

    // todo: nullable instead?
    init(sk1Transaction: SK1Transaction) {
        // todo: ?? ""
        self.productIdentifier = sk1Transaction.productIdentifier ?? ""
        self.purchaseDate = sk1Transaction.transactionDate ?? Date() // todo: ?
        self.transactionIdentifier = sk1Transaction.transactionIdentifier ?? UUID().description // todo: ?
    }

    let productIdentifier: String
    let purchaseDate: Date
    let transactionIdentifier: String

}

extension SKPaymentTransaction {

    /// Considering issue https://github.com/RevenueCat/purchases-ios/issues/279, sometimes `payment`
    /// and `productIdentifier` can be `nil`, in this case, they must be treated as nullable.
    /// Due of that an optional reference is created so that the compiler would allow us to check for nullability.
    var productIdentifier: String? {
        guard let payment = self.payment as SKPayment? else {
            Logger.appleWarning(Strings.purchase.skpayment_missing_from_skpaymenttransaction)
            return nil
        }

        guard let productIdentifier = payment.productIdentifier as String?,
              !productIdentifier.isEmpty else {
                  Logger.appleWarning(Strings.purchase.skpayment_missing_product_identifier)
                  return nil
              }

        return productIdentifier
    }

}

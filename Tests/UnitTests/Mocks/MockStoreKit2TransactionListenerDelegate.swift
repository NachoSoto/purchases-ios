//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  MockStoreKit2TransactionListenerDelegate.swift
//
//  Created by Nacho Soto on 11/14/22.

@testable import RevenueCat

@available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
final class MockStoreKit2TransactionListenerDelegate: StoreKit2TransactionListenerDelegate {

    var invokedTransactionsUpdated = false

    func transactionsUpdated() async throws {
        self.invokedTransactionsUpdated = true
    }

}

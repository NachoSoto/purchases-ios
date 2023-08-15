//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  MockPostedTransactionCache.swift
//
//  Created by Nacho Soto on 7/28/23.

@testable import RevenueCat

final class MockPostedTransactionCache: PostedTransactionCacheType {

    private let cache: Atomic<Set<String>> = .init([])

    var postedTransactions: Set<String> { self.cache.value }

    func savePostedTransaction(_ transaction: StoreTransactionType) {
        self.cache.modify { $0.insert(transaction.transactionIdentifier) }
    }

    func hasPostedTransaction(_ transaction: StoreTransactionType) -> Bool {
        return self.cache.value.contains(transaction.transactionIdentifier)
    }

    func unpostedTransactions<T: StoreTransactionType>(in transactions: [T]) -> [T] {
        return Self.unpostedTransactions(in: transactions, with: self.postedTransactions)
    }

}

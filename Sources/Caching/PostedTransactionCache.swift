//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PostedTransactionCache.swift
//
//  Created by Nacho Soto on 7/27/23.

import Foundation

/// A type that can keep track of which transactions have been posted to the backend.
protocol PostedTransactionCacheType: Sendable {

    func savePostedTransaction(_ transaction: StoreTransactionType)
    func hasPostedTransaction(_ transaction: StoreTransactionType) -> Bool

    /// - Returns: the subset of `transactions` that have not been posted.
    func unpostedTransactions<T: StoreTransactionType>(in transactions: [T]) -> [T]

}

final class PostedTransactionCache: PostedTransactionCacheType {

    private typealias StoredTransactions = Set<String>

    private let deviceCache: DeviceCache

    init(deviceCache: DeviceCache) {
        self.deviceCache = deviceCache

        RCIntegrationTestAssert(
            self.storedTransactions.isEmpty,
            "Found stored transactions when initializing cache: \(self.storedTransactions)"
        )
    }

    func savePostedTransaction(_ transaction: StoreTransactionType) {
        RCIntegrationTestAssertNotMainThread()

        self.deviceCache.update(key: CacheKey.transactions,
                                default: StoredTransactions()) { transactions in
            transactions.insert(transaction.transactionIdentifier)
        }
    }

    func hasPostedTransaction(_ transaction: StoreTransactionType) -> Bool {
        RCIntegrationTestAssertNotMainThread()

        return self.storedTransactions.contains(transaction.transactionIdentifier)
    }

    func unpostedTransactions<T: StoreTransactionType>(in transactions: [T]) -> [T] {
        RCIntegrationTestAssertNotMainThread()

        return Self.unpostedTransactions(in: transactions, with: self.storedTransactions)
    }

    // MARK: -

    private var storedTransactions: StoredTransactions {
        return self.deviceCache.value(for: CacheKey.transactions) ?? []
    }

}

extension PostedTransactionCacheType {

    static func unpostedTransactions<T: StoreTransactionType>(
        in transactions: [T],
        with postedTransactions: Set<String>
    ) -> [T] {
        return transactions.filter { !postedTransactions.contains($0.transactionIdentifier) }
    }

}

private extension PostedTransactionCache {

    enum CacheKey: String, DeviceCacheKeyType {

        case transactions = "com.revenuecat.cached_transaction_identifier"

    }

}

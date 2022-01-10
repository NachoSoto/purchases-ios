//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  StoreTransactionTests.swift
//
//  Created by Nacho Soto on 1/10/22.

import Nimble
@testable import RevenueCat
import StoreKitTest
import XCTest

class StoreTransactionTests: StoreKitConfigTestCase {

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
    func testSK2DetailsWrapCorrectly() async throws {
        try AvailabilityChecks.iOS15APIAvailableOrSkipTest()

        let sk2Transaction = try await self.simulateAnyPurchase()

        let transaction = StoreTransaction(sk2Transaction: sk2Transaction)

        expect(transaction.sk2Transaction) === sk2Transaction

        expect(transaction.productIdentifier) == Self.productID
        expect(transaction.purchaseDate.timeIntervalSinceNow) <= 5
        expect(transaction.productIdentifier) == String(sk2Transaction.id)
    }
}

private extension StoreTransactionTests {

    static let productID = "com.revenuecat.monthly_4.99.1_week_intro"

    @MainActor
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    func simulateAnyPurchase() async throws -> SK2Transaction {
        let product = try await fetchSk2Product()
        _ = try await product.purchase()

        let latestTransaction = await product.latestTransaction
        let transaction = try XCTUnwrap(latestTransaction)

        switch transaction {
        case let .verified(transaction):
            return transaction
        default:
            XCTFail("Invalid transaction: \(transaction)")
            fatalError("Unreachable")
        }
    }

    @MainActor
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    private func fetchSk2Product() async throws -> SK2Product {
        let products: [Any] = try await StoreKit.Product.products(for: [Self.productID])
        return try XCTUnwrap(products.first as? SK2Product)
    }

}

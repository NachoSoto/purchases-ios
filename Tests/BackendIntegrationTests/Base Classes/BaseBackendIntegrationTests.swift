//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  BaseBackendIntegrationTests.swift
//
//  Created by Nacho Soto on 4/1/22.

import Nimble
@testable import RevenueCat
import XCTest

final class TestPurchaseDelegate: NSObject, PurchasesDelegate, Sendable {

    private let _customerInfo: Atomic<CustomerInfo?> = nil
    private let _customerInfoUpdateCount: Atomic<Int> = .init(0)

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        self._customerInfo.value = customerInfo
        self._customerInfoUpdateCount.value += 1
    }

    var customerInfo: CustomerInfo? { return self._customerInfo.value }
    var customerInfoUpdateCount: Int { return self._customerInfoUpdateCount.value }

}

@MainActor
class BaseBackendIntegrationTests: CommonBackendIntegrationTests {

    // swiftlint:disable:next weak_delegate
    private(set) var purchasesDelegate: TestPurchaseDelegate!

    // MARK: - Overridable configuration

    class var storeKit2Setting: StoreKit2Setting { return .default }
    class var observerMode: Bool { return false }
    class var responseVerificationMode: Signing.ResponseVerificationMode {
        return .enforced(Signing.loadPublicKey())
    }

    override func configurePurchases() async {
        self.purchasesDelegate = TestPurchaseDelegate()

        Purchases.configure(withAPIKey: self.apiKey,
                            appUserID: nil,
                            observerMode: Self.observerMode,
                            userDefaults: self.userDefaults,
                            platformInfo: nil,
                            responseVerificationMode: Self.responseVerificationMode,
                            storeKit2Setting: Self.storeKit2Setting,
                            storeKitTimeout: Configuration.storeKitRequestTimeoutDefault,
                            networkTimeout: Configuration.networkTimeoutDefault,
                            dangerousSettings: self.dangerousSettings)

        Purchases.shared.delegate = self.purchasesDelegate
        Purchases.logLevel = .verbose
    }

    override func loadOfferings() async {
        _ = try? await Purchases.shared.offerings()
    }

    // MARK: -

    @MainActor
    override func setUp() async throws {
        if !Constants.proxyURL.isEmpty {
            Purchases.proxyURL = URL(string: Constants.proxyURL)
        }

        try await super.setUp()

        self.verifyPurchasesDoesNotLeak()
    }

    /// Simulates closing the app and re-opening with a fresh instance of `Purchases`.
    final func resetSingleton() async {
        Logger.warn("Resetting Purchases.shared")

        Purchases.clearSingleton()
        await self.configurePurchases()
    }

}

private extension BaseBackendIntegrationTests {

    func verifyPurchasesDoesNotLeak() {
        // See `addTeardownBlock` docs:
        // - These run *before* `tearDown`.
        // - They run in LIFO order.
        self.addTeardownBlock { [weak purchases = Purchases.shared] in
            expect(purchases).toEventually(beNil(), description: "Purchases has leaked")
        }

        self.addTeardownBlock {
            Purchases.shared.delegate = nil
            Purchases.clearSingleton()
        }
    }

    private var dangerousSettings: DangerousSettings {
        return .init(autoSyncPurchases: true,
                     internalSettings: self)
    }

}

extension BaseBackendIntegrationTests: InternalDangerousSettingsType {

    var enableReceiptFetchRetry: Bool { return true }
    var forceServerErrors: Bool { return false }

}

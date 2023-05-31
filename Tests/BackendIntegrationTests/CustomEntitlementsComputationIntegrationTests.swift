//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  CustomEntitlementsComputationIntegrationTests.swift
//
//  Created by Nacho Soto on 5/31/23.

import Nimble
import RevenueCat_CustomEntitlementComputation
import StoreKit
import StoreKitTest
import XCTest

// swiftlint:disable type_name

final class CustomEntitlementsComputationIntegrationTests: CommonBackendIntegrationTests {

    private var logger: TestLogHandler!
    private var testSession: SKTestSession!

    override class func setUp() {
        TestLogHandler.changeVerboseLogHandler { Purchases.verboseLogHandler = $0 }
    }

    override func setUp() async throws {
        self.logger = .init()
        self.testSession = try StoreKitTestSessionFactory.create()

        try await super.setUp()
    }

    override func tearDown() {
        // No `GetCustomerInfoOperation` requests should be made
        self.logger.verifyMessageWasNotLogged("GetCustomerInfoOperation")

        self.testSession = nil

        super.tearDown()
    }

    override func configurePurchases() async {
        Purchases.configureInCustomEntitlementsComputationMode(apiKey: self.apiKey, appUserID: Self.userID)
    }

    override func loadOfferings() async {
        _ = try? await Purchases.shared.offerings()
    }

    private static let userID = UUID().uuidString

    // MARK: - Tests

    func testPurchasesDiagnostics() async throws {
        try await PurchasesDiagnostics.default.testSDKHealth()
    }

    func testCanGetOfferings() async throws {
        let receivedOfferings = try await Purchases.shared.offerings()
        expect(receivedOfferings.all).toNot(beEmpty())
    }

    func testCanSwitchUser() async throws {
        let newUser = UUID().uuidString

        Purchases.shared.switchUser(to: newUser)

        let info = try await Purchases.shared.purchase(package: self.monthlyPackage).customerInfo
        expect(info.originalAppUserId) == newUser
    }

    func testCanPurchasePackage() async throws {
        let info = try await Purchases.shared.purchase(package: self.monthlyPackage).customerInfo
        expect(info.entitlements.active).to(haveCount(1))
        expect(info.entitlements.active.values.first?.identifier) == "premium"
    }

}

private extension CustomEntitlementsComputationIntegrationTests {

    var monthlyPackage: Package {
        get async throws {
            let offerings = try await Purchases.shared.offerings()
            return try XCTUnwrap(offerings.current?.monthly)
        }
    }

}

//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  TrialOrIntroEligibilityCheckerIntegrations.swift
//
//  Created by Nacho Soto on 4/6/22.

import Nimble
@testable import RevenueCat
import StoreKitTest
import XCTest

// swiftlint:disable type_name

//class TrialOrIntroEligibilityCheckerStoreKit2IntegrationTests: TrialOrIntroEligibilityCheckerStoreKit1IntegrationTests {
//
//    override class var sk2Enabled: Bool { return true }
//
//}
//
//class TrialOrIntroEligibilityCheckerStoreKit1IntegrationTests: BaseBackendIntegrationTests {
//
//    private var testSession: SKTestSession!
//    private var checker: TrialOrIntroPriceEligibilityChecker!
//
//    override func setUpWithError() throws {
//        try super.setUpWithError()
//
//        let systemInfo: SystemInfo = try .init(platformInfo: nil,
//                                               finishTransactions: false,
//                                               useStoreKit2IfAvailable: Self.sk2Enabled)
//        let backend: Backend = .init(httpClient: .init(systemInfo: systemInfo, eTagManager: .init()),
//                                     apiKey: Constants.apiKey,
//                                     attributionFetcher: .init(attributionFactory: .init(),
//                                                               systemInfo: systemInfo))
//        self.checker = .init(
//            receiptFetcher: .init(requestFetcher: .init(operationDispatcher: .default),
//                                  systemInfo: systemInfo),
//            introEligibilityCalculator: .init(productsManager: .init(systemInfo: systemInfo),
//                                              receiptParser: .init()),
//            backend: backend,
//            identityManager: .init(deviceCache: .init(systemInfo: systemInfo),
//                                   backend: backend,
//                                   customerInfoManager: .init(operationDispatcher: <#T##OperationDispatcher#>, deviceCache: <#T##DeviceCache#>, backend: <#T##Backend#>, systemInfo: <#T##SystemInfo#>), appUserID: <#T##String?#>), operationDispatcher: <#T##OperationDispatcher#>, productsManager: <#T##ProductsManager#>)
//    }
//
//    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
//    func testEligibleForIntroBeforePurchaseAndIneligibleAfter() async throws {
//        try AvailabilityChecks.iOS15APIAvailableOrSkipTest()
//
//        let offerings = try await Purchases.shared.offerings()
//        let product = try XCTUnwrap(offerings.current?.monthly?.storeProduct)
//
//        var eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
//        expect(eligibility) == .eligible
//
//        let customerInfo = try await self.purchaseMonthlyOffering().customerInfo
//
//        expect(customerInfo.entitlements.all.count) == 1
//        let entitlements = self.purchasesDelegate.customerInfo?.entitlements
//        expect(entitlements?[Self.entitlementIdentifier]?.isActive) == true
//
//        let anonUserID = Purchases.shared.appUserID
//        let identifiedUserID = "\(#function)_\(anonUserID)_".replacingOccurrences(of: "RCAnonymous", with: "")
//
//        let (identifiedCustomerInfo, created) = try await Purchases.shared.logIn(identifiedUserID)
//        expect(created) == true
//        expect(identifiedCustomerInfo.entitlements[Self.entitlementIdentifier]?.isActive) == true
//
//        eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
//        expect(eligibility) == .ineligible
//    }
//
//}

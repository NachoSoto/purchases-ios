//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  CommonBackendIntegrationTests.swift
//
//  Created by Nacho Soto on 5/31/23.

import Nimble
import XCTest

/// Shared by `BackendIntegrationTests` and `BackendCustomEntitlementsIntegrationTests`.
@MainActor
class CommonBackendIntegrationTests: XCTestCase {

    private(set) var userDefaults: UserDefaults!
    private var mainThreadMonitor: MainThreadMonitor!

    // MARK: - Overridable configuration

    var apiKey: String { return Constants.apiKey }
    var proxyURL: String? { return Constants.proxyURL }

    func configurePurchases() async {
        fatalError("Must be overriden")
    }

    func loadOfferings() async {
        fatalError("Must be overriden")
    }

    // MARK: -

    @MainActor
    override func setUp() async throws {
        struct ConfigurationError: Error {}

        try await super.setUp()

        // Avoid continuing with potentially bad data after a failed assertion
        self.continueAfterFailure = false

        guard self.apiKey != "REVENUECAT_API_KEY",
              self.apiKey != "REVENUECAT_LOAD_SHEDDER_API_KEY",
              self.proxyURL != "REVENUECAT_PROXY_URL" else {
            // Must set configuration in `Constants.swift`
            throw ConfigurationError()
        }

        self.mainThreadMonitor = .init()
        self.mainThreadMonitor.run()

        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *) {
            // Despite calling `SKTestSession.clearTransactions` tests sometimes
            // begin with leftover transactions. This ensures that we remove them
            // to always start with a clean state.
            await self.finishAllUnfinishedTransactions()
        }

        self.userDefaults = UserDefaults(suiteName: Constants.userDefaultsSuiteName)
        self.userDefaults?.removePersistentDomain(forName: Constants.userDefaultsSuiteName)

        self.clearReceiptIfExists()
        await self.configurePurchases()
        await self.waitForAnonymousUser()
    }

    override func tearDown() {
        super.tearDown()

        self.mainThreadMonitor = nil
    }

}

private extension CommonBackendIntegrationTests {

    func waitForAnonymousUser() async {
        // SDK initialization begins with an initial request to offerings,
        // which results in a get-create of the initial anonymous user.
        // To avoid race conditions with when this request finishes and make all tests deterministic
        // this waits for that request to finish.
        //
        // This ignores errors because this class does not set up `SKTestSession`,
        // so subclasses would fail to load offerings if they don't set one up.
        // However, it still serves the purpose of waiting for the anonymous user.
        // If there is something broken when loading offerings, there is a dedicated test that would fail instead.
        await self.loadOfferings()
    }

    func clearReceiptIfExists() {
        let manager = FileManager.default

        guard let url = Bundle.main.appStoreReceiptURL, manager.fileExists(atPath: url.path) else { return }

        do {
            try manager.removeItem(at: url)
        } catch {
            print("Error attempting to remove receipt URL '\(url)': \(error)")
        }
    }

}

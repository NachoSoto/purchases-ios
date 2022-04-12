//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  CustomerInfoResponseTests.swift
//
//  Created by Nacho Soto on 4/12/22.

import Nimble
@testable import RevenueCat
import XCTest

class CustomerInfoResponseTests: BaseHTTPResponseTest {

    var response: CustomerInfoResponse!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.response = try self.decodeFixture("CustomerInfo")
    }

    func testResponseDataIsCorrect() {
        let subscriber = self.response.subscriber
        let dateFormatter = ISO8601DateFormatter()

        expect(self.response.requestDate) == Date(timeIntervalSince1970: 1646761378)
        expect(subscriber.originalAppUserId) == "$RCAnonymousID:5b6fdbac3a0c4f879e43d269ecdf9ba1"
        expect(subscriber.managementUrl) == URL(string: "https://apps.apple.com/account/subscriptions")
        expect(subscriber.originalApplicationVersion) == "1.0"
        expect(subscriber.originalPurchaseDate) == dateFormatter.date(from: "2022-04-12T00:03:24Z")
        expect(subscriber.firstSeen) == dateFormatter.date(from: "2022-03-08T17:42:58Z")
    }

    func testConvertToCustomerInfo() {
    }

    // TODO: errors?
}

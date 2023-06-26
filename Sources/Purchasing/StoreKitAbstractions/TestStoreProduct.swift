//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  TestStoreProduct.swift
//
//  Created by Nacho Soto on 6/23/23.

import Foundation

#if DEBUG

/// A type that contains the necessary data to create a ``StoreProduct``.
public struct TestStoreProduct {

    // Note: this class inherits its docs from `StoreProductType`
    // swiftlint:disable missing_docs

    public var localizedTitle: String
    public var price: Decimal
    public var localizedPriceString: String
    public var productIdentifier: String
    public var productType: StoreProduct.ProductType
    public var localizedDescription: String
    public var subscriptionGroupIdentifier: String?
    public var subscriptionPeriod: SubscriptionPeriod?
    public var introductoryDiscount: StoreProductDiscount?
    public var discounts: [StoreProductDiscount]

    // TODO: api tester

    public init(
        localizedTitle: String,
        price: Decimal,
        localizedPriceString: String,
        productIdentifier: String,
        productType: StoreProduct.ProductType,
        localizedDescription: String,
        subscriptionGroupIdentifier: String? = nil,
        subscriptionPeriod: SubscriptionPeriod? = nil,
        // TODO: TestStoreProductDiscount
        introductoryDiscount: StoreProductDiscount? = nil,
        // TODO: TestStoreProductDiscount
        discounts: [StoreProductDiscount] = []
    ) {
        self.localizedTitle = localizedTitle
        self.price = price
        self.localizedPriceString = localizedPriceString
        self.productIdentifier = productIdentifier
        self.productType = productType
        self.localizedDescription = localizedDescription
        self.subscriptionGroupIdentifier = subscriptionGroupIdentifier
        self.subscriptionPeriod = subscriptionPeriod
        self.introductoryDiscount = introductoryDiscount
        self.discounts = discounts
    }

    // swiftlint:enable missing_docs
}

// Ensure consistency with the internal type
extension TestStoreProduct: StoreProductType {

    internal var productCategory: StoreProduct.ProductCategory { return self.productType.productCategory }

    internal var currencyCode: String? { return nil }

    internal var isFamilyShareable: Bool { return false }

    internal var priceFormatter: NumberFormatter? { return nil }

}

extension TestStoreProduct {

    /// Convert it into a ``StoreProduct``.
    public func toProduct() -> StoreProduct {
        return .from(product: self)
    }

}

#else

@available(
    iOS,
    obsoleted: 1,
    message: "This API is only available for debug builds. Use #if DEBUG to conditionally compile it."
)
public struct TestStoreProduct {}

#endif

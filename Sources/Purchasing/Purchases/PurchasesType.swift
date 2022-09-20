//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PurchasesType.swift
//
//  Created by Nacho Soto on 9/20/22.

import Foundation

// swiftlint:disable missing_docs

/// Interface for ``Purchases``.
@objc(RCPurchasesType)
public protocol PurchasesType: AnyObject {
    var appUserID: String { get }
    var isAnonymous: Bool { get }
    var finishTransactions: Bool { get set }

    var delegate: PurchasesDelegate? { get set }

    func logIn(_ appUserID: String, completion: @escaping (CustomerInfo?, Bool, PublicError?) -> Void)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func logIn(_ appUserID: String) async throws -> (customerInfo: CustomerInfo, created: Bool)

    func logOut(completion: ((CustomerInfo?, PublicError?) -> Void)?)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func logOut() async throws -> CustomerInfo

    func getCustomerInfo(fetchPolicy: CacheFetchPolicy, completion: @escaping (CustomerInfo?, PublicError?) -> Void)
    func getCustomerInfo(completion: @escaping ((CustomerInfo?, PublicError?) -> Void))
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func customerInfo() async throws -> CustomerInfo
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func customerInfo(fetchPolicy: CacheFetchPolicy) async throws -> CustomerInfo

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    var customerInfoStream: AsyncStream<CustomerInfo> { get }

    func getOfferings(completion: @escaping ((Offerings?, PublicError?) -> Void))
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func offerings() async throws -> Offerings

    @objc(getProductsWithIdentifiers:completion:)
    func getProducts(_ productIdentifiers: [String], completion: @escaping ([StoreProduct]) -> Void)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func products(_ productIdentifiers: [String]) async -> [StoreProduct]

    @objc(purchaseProduct:withCompletion:)
    func purchase(product: StoreProduct, completion: @escaping PurchaseCompletedBlock)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func purchase(product: StoreProduct) async throws -> PurchaseResultData

    @objc(purchasePackage:withCompletion:)
    func purchase(package: Package, completion: @escaping PurchaseCompletedBlock)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func purchase(package: Package) async throws -> PurchaseResultData

    func restorePurchases(completion: ((CustomerInfo?, PublicError?) -> Void)?)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func restorePurchases() async throws -> CustomerInfo

    func syncPurchases(completion: ((CustomerInfo?, PublicError?) -> Void)?)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func syncPurchases() async throws -> CustomerInfo

    @objc(checkTrialOrIntroDiscountEligibility:completion:)
    func checkTrialOrIntroDiscountEligibility(
        productIdentifiers: [String],
        completion receiveEligibility: @escaping ([String: IntroEligibility]) -> Void
    )
    @available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
    func checkTrialOrIntroDiscountEligibility(productIdentifiers: [String]) async -> [String: IntroEligibility]

    @objc(checkTrialOrIntroDiscountEligibilityForProduct:completion:)
    func checkTrialOrIntroDiscountEligibility(
        product: StoreProduct,
        completion: @escaping (IntroEligibilityStatus) -> Void
    )
    @available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.2, *)
    func checkTrialOrIntroDiscountEligibility(product: StoreProduct) async -> IntroEligibilityStatus

    @available(iOS 12.2, macOS 10.14.4, macCatalyst 13.0, tvOS 12.2, watchOS 6.2, *)
    @objc(getPromotionalOfferForProductDiscount:withProduct:withCompletion:)
    func getPromotionalOffer(forProductDiscount discount: StoreProductDiscount,
                             product: StoreProduct,
                             completion: @escaping ((PromotionalOffer?, PublicError?) -> Void))
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func promotionalOffer(forProductDiscount discount: StoreProductDiscount,
                          product: StoreProduct) async throws -> PromotionalOffer

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func eligiblePromotionalOffers(forProduct product: StoreProduct) async -> [PromotionalOffer]

    @available(iOS 12.2, macOS 10.14.4, watchOS 6.2, macCatalyst 13.0, tvOS 12.2, *)
    @objc(purchaseProduct:withPromotionalOffer:completion:)
    func purchase(product: StoreProduct,
                  promotionalOffer: PromotionalOffer,
                  completion: @escaping PurchaseCompletedBlock)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func purchase(product: StoreProduct, promotionalOffer: PromotionalOffer) async throws -> PurchaseResultData

    @available(iOS 12.2, macOS 10.14.4, watchOS 6.2, macCatalyst 13.0, tvOS 12.2, *)
    @objc(purchasePackage:withPromotionalOffer:completion:)
    func purchase(package: Package,
                  promotionalOffer: PromotionalOffer,
                  completion: @escaping PurchaseCompletedBlock)
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
    func purchase(package: Package, promotionalOffer: PromotionalOffer) async throws -> PurchaseResultData

    func invalidateCustomerInfoCache()

    @available(iOS 15.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @objc(beginRefundRequestForProduct:completion:)
    func beginRefundRequest(forProduct productID: String) async throws -> RefundRequestStatus

    @available(iOS 15.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @objc(beginRefundRequestForEntitlement:completion:)
    func beginRefundRequest(forEntitlement entitlementID: String) async throws -> RefundRequestStatus

    @available(iOS 15.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @objc(beginRefundRequestForActiveEntitlementWithCompletion:)
    func beginRefundRequestForActiveEntitlement() async throws -> RefundRequestStatus

    @available(iOS 14.0, *)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(macCatalyst, unavailable)
    func presentCodeRedemptionSheet()

    #if os(iOS) || targetEnvironment(macCatalyst)
    @available(iOS 13.4, macCatalyst 13.4, *)
    @objc func showPriceConsentIfNeeded()
    #endif

    #if os(iOS) || os(macOS)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @available(iOS 13.0, macOS 10.15, *)
    @objc func showManageSubscriptions(completion: @escaping (PublicError?) -> Void)

    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    @available(iOS 13.0, macOS 10.15, *)
    func showManageSubscriptions() async throws
    #endif

    func setAttributes(_ attributes: [String: String])
    var attribution: Attribution { get }

    // MARK: - Deprecated

    @available(*, deprecated)
    var allowSharingAppStoreAccount: Bool { get set }
    @available(*, deprecated)
    func setEmail(_ email: String?)
    @available(*, deprecated)
    func setPhoneNumber(_ phoneNumber: String?)
    @available(*, deprecated)
    func setDisplayName(_ displayName: String?)
    @available(*, deprecated)
    func setPushToken(_ pushToken: Data?)
    @available(*, deprecated)
    func setPushTokenString(_ pushToken: String?)
    @available(*, deprecated)
    func setAdjustID(_ adjustID: String?)
    @available(*, deprecated)
    func setAppsflyerID(_ appsflyerID: String?)
    @available(*, deprecated)
    func setFBAnonymousID(_ fbAnonymousID: String?)
    @available(*, deprecated)
    func setMparticleID(_ mparticleID: String?)
    @available(*, deprecated)
    func setOnesignalID(_ onesignalID: String?)
    @available(*, deprecated)
    func setMediaSource(_ mediaSource: String?)
    @available(*, deprecated)
    func setCampaign(_ campaign: String?)
    @available(*, deprecated)
    func setAdGroup(_ adGroup: String?)
    @available(*, deprecated)
    func setAd(_ value: String?)
    @available(*, deprecated)
    func setKeyword(_ keyword: String?)
    @available(*, deprecated)
    func setCreative(_ creative: String?)
    @available(*, deprecated)
    func setCleverTapID(_ cleverTapID: String?)
    @available(*, deprecated)
    func setMixpanelDistinctID(_ mixpanelDistinctID: String?)
    @available(*, deprecated)
    func setFirebaseAppInstanceID(_ firebaseAppInstanceID: String?)
    @available(*, deprecated)
    func collectDeviceIdentifiers()
}

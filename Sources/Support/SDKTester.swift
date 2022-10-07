//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  SDKTester.swift
//
//  Created by Nacho Soto on 9/21/22.

import Foundation

// `SDKTester` is only available on DEBUG builds.

#if DEBUG

/// TODO: document
@objc(RCSDKTester)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
public final class SDKTester: NSObject {

    typealias SDK = PurchasesType & PurchasesSwiftType

    private let purchases: SDK

    init(purchases: SDK) {
        self.purchases = purchases
    }

    @objc
    public static let `default`: SDKTester = .init(purchases: Purchases.shared)
}

// MARK: -

// TODO: add to API tester?

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
extension SDKTester {

    enum Error: Swift.Error {

        case unknown(Swift.Error)
        case failedConectingToAPI(Swift.Error)
        case invalidServerResponse(response: Data)

    }

    // TODO: test and verify error logging
    @objc(testWithCompletion:)
    public func test() async throws {
        do {
            try await self.backendRequest()

        } catch let error as Error {
            throw error
        } catch let error {
            throw Error.unknown(error)
        }
    }

}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
private extension SDKTester {

    /// Makes a request to the backend, to verify connectivity, firewalls, or anything blocking network traffic.
    func backendRequest() async throws {
        do {
            try await Purchases.shared.healthRequest()
        } catch {
            throw Error.failedConectingToAPI(error)
        }
    }

//    func

    // - try making a request that uses an API key (api key okay)
    // - try fetching all product ids from the dashboard and fetching them from the store (device-side connection with store okay)
    // - try asking something for the backend that requires the backend to hit the store (backend-side connection with store okay)
    // - try fetching offerings (offerings config okay)

    func handle(_ error: ErrorCode) throws {
        switch error {
        case .unknownError: throw Error.unknown(error)

        default:
            fatalError("")
    //        case .purchaseCancelledError:
    //            <#code#>
    //        case .storeProblemError:
    //            <#code#>
    //        case .purchaseNotAllowedError:
    //            <#code#>
    //        case .purchaseInvalidError:
    //            <#code#>
    //        case .productNotAvailableForPurchaseError:
    //            <#code#>
    //        case .productAlreadyPurchasedError:
    //            <#code#>
    //        case .receiptAlreadyInUseError:
    //            <#code#>
    //        case .invalidReceiptError:
    //            <#code#>
    //        case .missingReceiptFileError:
    //            <#code#>
    //        case .networkError:
    //            <#code#>
    //        case .invalidCredentialsError:
    //            <#code#>
    //        case .unexpectedBackendResponseError:
    //            <#code#>
    //        case .receiptInUseByOtherSubscriberError:
    //            <#code#>
    //        case .invalidAppUserIdError:
    //            <#code#>
    //        case .operationAlreadyInProgressForProductError:
    //            <#code#>
    //        case .unknownBackendError:
    //            <#code#>
    //        case .invalidAppleSubscriptionKeyError:
    //            <#code#>
    //        case .ineligibleError:
    //            <#code#>
    //        case .insufficientPermissionsError:
    //            <#code#>
    //        case .paymentPendingError:
    //            <#code#>
    //        case .invalidSubscriberAttributesError:
    //            <#code#>
    //        case .logOutAnonymousUserError:
    //            <#code#>
    //        case .configurationError:
    //            <#code#>
    //        case .unsupportedError:
    //            <#code#>
    //        case .emptySubscriberAttributes:
    //            <#code#>
    //        case .productDiscountMissingIdentifierError:
    //            <#code#>
    //        case .productDiscountMissingSubscriptionGroupIdentifierError:
    //            <#code#>
    //        case .customerInfoError:
    //            <#code#>
    //        case .systemInfoError:
    //            <#code#>
    //        case .beginRefundRequestError:
    //            <#code#>
    //        case .productRequestTimedOut:
    //            <#code#>
    //        case .apiEndpointBlockedError:
    //            <#code#>
    //        case .invalidPromotionalOfferError:
    //            <#code#>
    //        case .offlineConnectionError:
    //            <#code#>
        }
    }


}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, *)
extension SDKTester.Error: CustomNSError {

    // TODO: descriptions (and test)

    var errorUserInfo: [String : Any] {
        return [
            NSUnderlyingErrorKey: self.underlyingError as NSError? ?? NSNull()
        ]
    }

    private var underlyingError: Swift.Error? {
        switch self {
        case let .unknown(error): return error
        case let .failedConectingToAPI(error): return error
        case .invalidServerResponse: return nil
        }
    }

}

#endif

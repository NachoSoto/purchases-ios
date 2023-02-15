//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  EntitlementValidation.swift
//
//  Created by Nacho Soto on 2/10/23.

import Foundation

// TODO: include link to docs

/// The result of the validation process for ``CustomerInfo`` and ``EntitlementInfo``.
///
/// This is accomplished by preventing MITM attacks between the SDK and the RevenueCat server.
/// With validation enabled, the SDK ensures that the response created by the server was not modified by a third-party,
/// and the entitlements received are exactly what was sent.
/// 
/// - Note: Entitlements are only validated if enabled using ``Configuration/Builder/with(entitlementValidationMode:)``,
/// which is disabled by default.
///
/// ### Example:
/// ```swift
/// let purchases = try Purchases.configure(
///   with: Configuration
///     .builder(withAPIKey: "")
///     .with(entitlementValidationMode: .informationOnly)
/// )
///
/// let customerInfo = try await purchases.customerInfo()
/// if customerInfo.entitlementValidation != .validated {
///   print("Entitlements could not be verified")
/// }
/// ```
///
/// ### Related Symbols
/// - ``Configuration/EntitlementValidationMode``
/// - ``Configuration/Builder/with(entitlementValidationMode:)``
/// - ``CustomerInfo/entitlementValidation``
/// - ``EntitlementInfos/validation``
@objc(RCEntitlementValidation)
public enum EntitlementValidation: Int {

    /// No validation was done.
    ///
    /// This can happen for multiple reasons:
    ///  1. Validation is not enabled in ``Configuration``
    ///  2. Validation can't be performed prior to iOS 13.0
    ///  3. Data was cached in an older version of the SDK not supporting validation
    case notValidated = 0

    /// Entitlements were validated with our server.
    case validated = 1

    /// Entitlement validation failed, possibly due to a MITM attack.
    /// ### Related Symbols
    /// - ``ErrorCode/signatureValidationFailed``
    case failedValidation = 2

}

extension EntitlementValidation: Sendable, Codable {}

extension HTTPResponseValidationResult {

    var entitlementValidation: EntitlementValidation {
        switch self {
        case .notRequested: return .notValidated
        case .validated: return .validated
        case .failedValidation: return .failedValidation
        }
    }

}

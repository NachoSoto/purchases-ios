//
//  EntitlementValidationAPI.swift
//  SwiftAPITester
//
//  Created by Nacho Soto on 2/10/23.
//

import Foundation
import RevenueCat

func checkEntitlementValidationAPI(_ mode: EntitlementValidationMode = .disabled,
                                   _ validation: EntitlementValidation = .notValidated) {
    switch mode {
    case .disabled,
            .informationOnly,
            .enforced:
        break

    @unknown default: break
    }

    switch validation {
    case .notValidated,
            .validated,
            .failedValidation:
        break

    @unknown default: break
    }
}

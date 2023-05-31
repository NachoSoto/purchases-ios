//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  StoreKitTestSession.swift
//
//  Created by Nacho Soto on 5/31/23.

import StoreKit
import StoreKitTest

enum StoreKitTestSessionFactory {

    static func create() throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: Constants.storeKitConfigFileName)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        if #available(iOS 15.2, *) {
            session.timeRate = .monthlyRenewalEveryThirtySeconds
        } else {
            session.timeRate = .oneSecondIsOneDay
        }

        return session
    }

}

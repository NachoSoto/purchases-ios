//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PaywallView.swift
//
//  Created by Nacho Soto.

import RevenueCat
import SwiftUI

/// A SwiftUI view for displaying a `PaywallData` for an `Offering`.
///
/// ### Related Articles
/// [Documentation](https://rev.cat/paywalls)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable, message: "RevenueCatUI does not support macOS yet")
@available(tvOS, unavailable, message: "RevenueCatUI does not support tvOS yet")
public struct PaywallView: View {

    private let mode: PaywallViewMode
    private let fonts: PaywallFontProvider

    @StateObject
    private var purchaseHandler: PurchaseHandler

    @StateObject
    private var introEligibility: TrialOrIntroEligibilityChecker

    @State
    private var offering: Offering?
    @State
    private var customerInfo: CustomerInfo?
    @State
    private var error: NSError?

    /// Create a view that loads the `Offerings.current`.
    /// - Note: If loading the current `Offering` fails (if the user is offline, for example),
    /// an error will be displayed.
    /// - Warning: `Purchases` must have been configured prior to displaying it.
    /// If you want to handle that, you can use ``init(offering:)`` instead.
    public init(
        fonts: PaywallFontProvider = DefaultPaywallFontProvider()
    ) {
        self.init(
            offering: nil,
            customerInfo: nil,
            fonts: fonts,
            introEligibility: nil,
            purchaseHandler: nil
        )
    }

    /// Create a view for the given `Offering`.
    /// - Note: if `offering` does not have a current paywall, or it fails to load due to invalid data,
    /// a default paywall will be displayed.
    /// - Warning: `Purchases` must have been configured prior to displaying it.
    public init(
        offering: Offering,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider()
    ) {
        self.init(
            offering: offering,
            customerInfo: nil,
            fonts: fonts,
            introEligibility: nil,
            purchaseHandler: nil
        )
    }

    init(
        offering: Offering?,
        customerInfo: CustomerInfo?,
        mode: PaywallViewMode = .default,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        introEligibility: TrialOrIntroEligibilityChecker?,
        purchaseHandler: PurchaseHandler?
    ) {
        self._offering = .init(initialValue: offering)
        self._customerInfo = .init(initialValue: customerInfo)
        self._introEligibility = .init(wrappedValue: introEligibility ?? .default())
        self._purchaseHandler = .init(wrappedValue: purchaseHandler ?? .default())
        self.mode = mode
        self.fonts = fonts
    }

    // swiftlint:disable:next missing_docs
    public var body: some View {
        self.content
            .displayError(self.$error, dismissOnClose: true)
    }

    @MainActor
    @ViewBuilder
    private var content: some View {
        VStack { // Necessary to work around FB12674350 and FB12787354
            if self.introEligibility.isConfigured, self.purchaseHandler.isConfigured {
                if let offering = self.offering, let customerInfo = self.customerInfo {
                    self.paywallView(for: offering,
                                     activelySubscribedProductIdentifiers: customerInfo.activeSubscriptions,
                                     fonts: self.fonts,
                                     checker: self.introEligibility,
                                     purchaseHandler: self.purchaseHandler)
                    .transition(Self.transition)
                } else {
                    LoadingPaywallView(mode: self.mode)
                        .transition(Self.transition)
                        .task {
                            do {
                                guard Purchases.isConfigured else {
                                    throw PaywallError.purchasesNotConfigured
                                }

                                if self.offering == nil {
                                    guard let offering = try await Purchases.shared.offerings().current else {
                                        throw PaywallError.noCurrentOffering
                                    }
                                    self.offering = offering
                                }

                                if self.customerInfo == nil {
                                    self.customerInfo = try await Purchases.shared.customerInfo()
                                }
                            } catch let error as NSError {
                                self.error = error
                            }
                        }
                }
            } else {
                DebugErrorView("Purchases has not been configured.", releaseBehavior: .fatalError)
            }
        }
    }

    @ViewBuilder
    private func paywallView(
        for offering: Offering,
        activelySubscribedProductIdentifiers: Set<String>,
        fonts: PaywallFontProvider,
        checker: TrialOrIntroEligibilityChecker,
        purchaseHandler: PurchaseHandler
    ) -> some View {
        let (paywall, template, error) = offering.validatedPaywall()

        let paywallView = LoadedOfferingPaywallView(
            offering: offering,
            activelySubscribedProductIdentifiers: activelySubscribedProductIdentifiers,
            paywall: paywall,
            template: template,
            mode: self.mode,
            fonts: fonts,
            introEligibility: checker,
            purchaseHandler: purchaseHandler
        )

        if let error {
            DebugErrorView(
                "\(error.description)\n" +
                "You can fix this by editing the paywall in the RevenueCat dashboard.\n" +
                "The displayed paywall contains default configuration.\n" +
                "This error will be hidden in production.",
                replacement: paywallView
            )
        } else {
            paywallView
        }
    }

    private static let transition: AnyTransition = .opacity.animation(Constants.defaultAnimation)

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(tvOS, unavailable)
struct LoadedOfferingPaywallView: View {

    private let offering: Offering
    private let activelySubscribedProductIdentifiers: Set<String>
    private let paywall: PaywallData
    private let template: PaywallTemplate
    private let mode: PaywallViewMode
    private let fonts: PaywallFontProvider

    @State
    private var session: (lastPaywall: DisplayedPaywall, id: PaywallEvent.SessionID)

    @StateObject
    private var introEligibility: IntroEligibilityViewModel
    @ObservedObject
    private var purchaseHandler: PurchaseHandler

    @Environment(\.locale)
    private var locale

    @Environment(\.colorScheme)
    private var colorScheme

    init(
        offering: Offering,
        activelySubscribedProductIdentifiers: Set<String>,
        paywall: PaywallData,
        template: PaywallTemplate,
        mode: PaywallViewMode,
        fonts: PaywallFontProvider,
        introEligibility: TrialOrIntroEligibilityChecker,
        purchaseHandler: PurchaseHandler
    ) {
        self.offering = offering
        self.activelySubscribedProductIdentifiers = activelySubscribedProductIdentifiers
        self.paywall = paywall
        self.template = template
        self.mode = mode
        self.fonts = fonts
        self._introEligibility = .init(
            wrappedValue: .init(introEligibilityChecker: introEligibility)
        )
        self._purchaseHandler = .init(initialValue: purchaseHandler)

        // Each `PaywallView` impression gets its own session.
        // See also `updateSessionIfNeeded`.
        self._session = .init(initialValue: (
            lastPaywall: .init(offering: offering, paywall: paywall),
            id: .init()
        ))
    }

    var body: some View {
        let view = self.paywall
            .createView(for: self.offering,
                        activelySubscribedProductIdentifiers: self.activelySubscribedProductIdentifiers,
                        template: self.template,
                        mode: self.mode,
                        fonts: self.fonts,
                        introEligibility: self.introEligibility,
                        locale: self.locale)
            .environmentObject(self.introEligibility)
            .environmentObject(self.purchaseHandler)
            .preference(key: PurchasedCustomerInfoPreferenceKey.self,
                        value: self.purchaseHandler.purchasedCustomerInfo)
            .preference(key: RestoredCustomerInfoPreferenceKey.self,
                        value: self.purchaseHandler.restoredCustomerInfo)
            .disabled(self.purchaseHandler.actionInProgress)
            .onAppear { self.purchaseHandler.trackPaywallImpression(self.eventData) }
            .onDisappear { self.purchaseHandler.trackPaywallClose(self.eventData) }

        switch self.mode {
        case .fullScreen:
            view

        case .footer, .condensedFooter:
            view
                .fixedSize(horizontal: false, vertical: true)
                .edgesIgnoringSafeArea(.bottom)
        }
    }

    private var eventData: PaywallEvent.Data {
        self.updateSessionIfNeeded()

        return .init(
            offering: self.offering,
            paywall: self.paywall,
            sessionID: self.session.id,
            displayMode: self.mode,
            locale: .current,
            darkMode: self.colorScheme == .dark
        )
    }

    private func updateSessionIfNeeded() {
        let newPaywall: DisplayedPaywall = .init(offering: self.offering, paywall: self.paywall)
        guard self.session.lastPaywall != newPaywall else { return }

        self.session.lastPaywall = newPaywall
        self.session.id = .init()
    }

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension LoadedOfferingPaywallView {

    struct DisplayedPaywall: Equatable {
        var offeringIdentifier: String
        var paywallTemplate: String
        var revision: Int

        init(offering: Offering, paywall: PaywallData) {
            self.offeringIdentifier = offering.identifier
            self.paywallTemplate = paywall.templateName
            self.revision = paywall.revision
        }
    }

}

// MARK: -

#if DEBUG

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
struct PaywallView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(Self.offerings, id: \.self) { offering in
            ForEach(Self.modes, id: \.self) { mode in
                PaywallView(
                    offering: offering,
                    customerInfo: TestData.customerInfo,
                    mode: mode,
                    introEligibility: PreviewHelpers.introEligibilityChecker,
                    purchaseHandler: PreviewHelpers.purchaseHandler
                )
                .previewLayout(mode.layout)
                .previewDisplayName("\(offering.paywall?.templateName ?? "")-\(mode)")
            }
        }
    }

    private static let offerings: [Offering] = [
        TestData.offeringWithIntroOffer,
        TestData.offeringWithMultiPackagePaywall,
        TestData.offeringWithSinglePackageFeaturesPaywall
    ]

    private static let modes: [PaywallViewMode] = [
        .fullScreen
    ]

    private static let colors: PaywallData.Configuration.ColorInformation = .init(
        light: TestData.lightColors,
        dark: TestData.darkColors
    )

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private extension PaywallViewMode {

    var layout: PreviewLayout {
        switch self {
        case .fullScreen: return .device
        case .footer, .condensedFooter: return .sizeThatFits
        }
    }

}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private extension PaywallTemplate {

    var name: String {
        switch self {
        case .template1: return "Minimalist"
        case .template2: return "Bold Packages"
        case .template3: return "Feature List"
        case .template4: return "Horizontal"
        case .template5: return "Small Banner"
        }
    }

}

#endif

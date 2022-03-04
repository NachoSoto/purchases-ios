//
// Created by RevenueCat on 2/27/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Nimble
import XCTest

@testable import RevenueCat

class BackendSubscriberAttributesTests: XCTestCase {

    private let appUserID = "abc123"
    private let referenceDate = Date(timeIntervalSinceReferenceDate: 700000000) // 2023-03-08 20:26:40
    private let receiptData = "an awesome receipt".data(using: String.Encoding.utf8)!
    private static let apiKey = "the api key"

    var dateProvider: MockDateProvider!
    var subscriberAttribute1: SubscriberAttribute!
    var subscriberAttribute2: SubscriberAttribute!
    var mockHTTPClient: MockHTTPClient!
    var mockETagManager: MockETagManager!
    var backend: Backend!

    let validSubscriberResponse: [String: Any] = [
        "request_date": "2019-08-16T10:30:42Z",
        "subscriber": [
            "first_seen": "2019-07-17T00:05:54Z",
            "original_app_user_id": "app_user_id",
            "subscriptions": [
                "onemonth_freetrial": [
                    "expires_date": "2017-08-30T02:40:36Z"
                ]
            ]
        ]
    ]

    // swiftlint:disable:next force_try
    let systemInfo = try! SystemInfo(platformInfo: .init(flavor: "Unity", version: "2.3.3"), finishTransactions: true)

    override func setUp() {
        mockETagManager = MockETagManager(userDefaults: MockUserDefaults())
        mockHTTPClient = MockHTTPClient(systemInfo: systemInfo, eTagManager: mockETagManager)
        self.backend = Backend(httpClient: mockHTTPClient, apiKey: Self.apiKey)
        dateProvider = MockDateProvider(stubbedNow: self.referenceDate)
        subscriberAttribute1 = SubscriberAttribute(withKey: "a key",
                                                   value: "a value",
                                                   dateProvider: dateProvider)

        subscriberAttribute2 = SubscriberAttribute(withKey: "another key",
                                                   value: "another value",
                                                   dateProvider: dateProvider)
    }

    override class func setUp() {
        XCTestObservationCenter.shared.addTestObserver(CurrentTestCaseTracker.shared)
    }

    override class func tearDown() {
        XCTestObservationCenter.shared.removeTestObserver(CurrentTestCaseTracker.shared)
    }

    // MARK: PostSubscriberAttributes

    func testPostSubscriberAttributesSendsRightParameters() {
        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { (_: Error!) in })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(self.mockHTTPClient.invokedPerformRequest) == true

        guard let receivedParameters = mockHTTPClient.invokedPerformRequestParameters else {
            fatalError("no parameters sent!")
        }

        expect(receivedParameters.request.path) == .postSubscriberAttributes(appUserID: self.appUserID)
        expect(receivedParameters.request.methodType) == .post
        expect(receivedParameters.headers) == HTTPClient.authorizationHeader(withAPIKey: Self.apiKey)
    }

    func testPostSubscriberAttributesCallsCompletionInSuccessCase() {
        var completionCallCount = 0
        mockHTTPClient.shouldInvokeCompletion = true

        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { (_: Error!) in
            completionCallCount += 1
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(completionCallCount).toEventually(equal(1))
    }

    func testPostSubscriberAttributesCallsCompletionInNetworkErrorCase() {
        var completionCallCount = 0
        mockHTTPClient.shouldInvokeCompletion = true
        let underlyingError = NSError(domain: "domain", code: 0, userInfo: nil)

        mockHTTPClient.stubbedCompletionError = ErrorUtils.networkError(withUnderlyingError: underlyingError)

        var receivedError: Error?
        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { (error: Error!) in
            completionCallCount += 1
            receivedError = error
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(completionCallCount).toEventually(equal(1))
        expect(receivedError).toNot(beNil())
        expect(receivedError).to(beAKindOf(Error.self))
        let receivedNSError = receivedError! as NSError

        expect(receivedNSError.code) == ErrorCode.networkError.rawValue
        expect(receivedNSError.successfullySynced) == false
    }

    func testPostSubscriberAttributesCallsCompletionWithErrorInBackendErrorCase() throws {
        var completionCallCount = 0
        mockHTTPClient.shouldInvokeCompletion = true
        mockHTTPClient.stubbedCompletionStatusCode = .other(503)
        mockHTTPClient.stubbedCompletionError = nil

        var receivedError: Error?
        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { (error: Error!) in
            completionCallCount += 1
            receivedError = error
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(completionCallCount).toEventually(equal(1))
        expect(receivedError).toNot(beNil())
        expect(receivedError).to(beAKindOf(Error.self))

        let receivedNSError = receivedError! as NSError
        expect(receivedNSError.code) == ErrorCode.unknownBackendError.rawValue
        expect(receivedNSError.successfullySynced) == false
        let successfulSyncedKey = try XCTUnwrap(receivedNSError.userInfo[Backend.RCSuccessfullySyncedKey as String])
        let successfulSyncedKeyBoolValue = try XCTUnwrap((successfulSyncedKey as? NSNumber)?.boolValue)

        expect(successfulSyncedKeyBoolValue) == false
    }

    func testPostSubscriberAttributesSendsAttributesErrorsIfAny() {
        var completionCallCount = 0
        mockHTTPClient.shouldInvokeCompletion = true
        mockHTTPClient.stubbedCompletionStatusCode = .other(503)
        mockHTTPClient.stubbedCompletionError = nil
        let attributeErrors = [Backend.RCAttributeErrorsKey: ["some_attribute": "wasn't valid"]]
        mockHTTPClient.stubbedCompletionResponse = attributeErrors

        var receivedError: Error?
        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { (error: Error!) in
            completionCallCount += 1
            receivedError = error
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(completionCallCount).toEventually(equal(1))
        expect(receivedError).toNot(beNil())
        expect(receivedError).to(beAKindOf(Error.self))

        let receivedNSError = receivedError! as NSError
        expect(receivedNSError.code) == ErrorCode.unknownBackendError.rawValue
        expect(receivedNSError.userInfo[Backend.RCAttributeErrorsKey]).toNot(beNil())

        let receivedAttributeErrors = receivedNSError.userInfo[Backend.RCAttributeErrorsKey]
        guard let receivedAttributeErrors = receivedAttributeErrors as? [String: String] else {
            fail("received attribute errors are not of type [String: String]")
            return
        }
        expect(receivedAttributeErrors) == ["some_attribute": "wasn't valid"]
    }

    func testPostSubscriberAttributesCallsCompletionWithErrorInBadRequestCase() throws {
        var completionCallCount = 0
        mockHTTPClient.shouldInvokeCompletion = true
        mockHTTPClient.stubbedCompletionStatusCode = .invalidRequest
        mockHTTPClient.stubbedCompletionError = nil

        var receivedError: Error?
        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { (error: Error!) in
            completionCallCount += 1
            receivedError = error

        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(completionCallCount).toEventually(equal(1))
        expect(receivedError).toNot(beNil())
        expect(receivedError).to(beAKindOf(Error.self))

        let receivedNSError = receivedError! as NSError
        expect(receivedNSError.code) == ErrorCode.unknownBackendError.rawValue
        expect(receivedNSError.successfullySynced) == true

        let successfulSyncedKey = try XCTUnwrap(receivedNSError.userInfo[Backend.RCSuccessfullySyncedKey as String])
        let successfulSyncedKeyBoolValue = try XCTUnwrap((successfulSyncedKey as? NSNumber)?.boolValue)

        expect(successfulSyncedKeyBoolValue) == true
    }

    func testPostSubscriberAttributesNoOpIfAttributesAreEmpty() {
        var completionCallCount = 0
        backend.post(subscriberAttributes: [:],
                     appUserID: appUserID,
                     completion: { (_: Error!) in
            completionCallCount += 1

        })
        expect(self.mockHTTPClient.invokedPerformRequestCount) == 0
    }

    func testPostSubscriberAttributesCallsCompletionWithErrorInNotFoundCase() throws {
        var completionCallCount = 0
        mockHTTPClient.shouldInvokeCompletion = true
        mockHTTPClient.stubbedCompletionStatusCode = .notFoundError
        mockHTTPClient.stubbedCompletionError = nil

        var receivedError: Error?
        backend.post(subscriberAttributes: [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ],
                     appUserID: appUserID,
                     completion: { error in
            completionCallCount += 1
            receivedError = error
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(completionCallCount).toEventually(equal(1))
        expect(receivedError).toNot(beNil())
        expect(receivedError).to(beAKindOf(Error.self))

        let receivedNSError = receivedError! as NSError
        expect(receivedNSError.code) == ErrorCode.unknownBackendError.rawValue
        expect(receivedNSError.successfullySynced) == false

        let successfulSyncedKey = try XCTUnwrap(receivedNSError.userInfo[Backend.RCSuccessfullySyncedKey as String])
        let successfulSyncedKeyBoolValue = try XCTUnwrap((successfulSyncedKey as? NSNumber)?.boolValue)

        expect(successfulSyncedKeyBoolValue) == false
    }

    // MARK: PostReceipt with subscriberAttributes

    func testPostReceiptWithSubscriberAttributesSendsThemCorrectly() throws {
        var completionCallCount = 0

        let subscriberAttributesByKey: [String: SubscriberAttribute] = [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ]

        backend.post(receiptData: receiptData,
                     appUserID: appUserID,
                     isRestore: false,
                     productData: nil,
                     presentedOfferingIdentifier: nil,
                     observerMode: false,
                     subscriberAttributes: subscriberAttributesByKey,
                     completion: { (_, _) in
            completionCallCount += 1
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
    }

    func testPostReceiptWithSubscriberAttributesReturnsBadJson() {
        let subscriberAttributesByKey: [String: SubscriberAttribute] = [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ]

        var receivedError: Error?
        var receivedCustomerInfo: CustomerInfo?
        backend.post(receiptData: receiptData,
                     appUserID: appUserID,
                     isRestore: false,
                     productData: nil,
                     presentedOfferingIdentifier: nil,
                     observerMode: false,
                     subscriberAttributes: subscriberAttributesByKey,
                     completion: { (customerInfo, error) in
            receivedError = error
            receivedCustomerInfo = customerInfo
        })

        expect(receivedCustomerInfo).toEventually(beNil())
        expect(receivedError).toEventuallyNot(beNil())

        guard let nsError = receivedError as NSError? else {
            fail("receivedError is nil")
            return
        }

        expect(nsError.domain) == RevenueCat.ErrorCode._nsErrorDomain
        expect(nsError.code) == ErrorCode.unexpectedBackendResponseError.rawValue

        guard let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError else {
            fail("Underlying error missing")
            return
        }

        expect(underlyingError.domain) == "RevenueCat.UnexpectedBackendResponseSubErrorCode"
        expect(underlyingError.code) == UnexpectedBackendResponseSubErrorCode.customerInfoResponseParsing.rawValue

        guard let parsingError = underlyingError.userInfo[NSUnderlyingErrorKey] as? NSError else {
            fail("Additional error details missing")
            return
        }

        expect(parsingError.domain) == "RevenueCat.CustomerInfoError"
        expect(parsingError.code) == CustomerInfoError.missingJsonObject.rawValue
    }

    func testPostReceiptWithoutSubscriberAttributesSkipsThem() throws {
        var completionCallCount = 0

        backend.post(receiptData: receiptData,
                     appUserID: appUserID,
                     isRestore: false,
                     productData: nil,
                     presentedOfferingIdentifier: nil,
                     observerMode: false,
                     subscriberAttributes: nil,
                     completion: { (_, _) in
            completionCallCount += 1
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
    }

    func testPostReceiptWithSubscriberAttributesPassesErrorsToCallbackIfStatusCodeIsError() {
        var completionCallCount = 0

        self.mockHTTPClient.stubbedCompletionStatusCode = .invalidRequest
        let attributeErrors = [
            Backend.RCAttributeErrorsKey: ["$email": "email is not in valid format"]
        ]
        let attributesErrorsResponse = [
            Backend.RCAttributeErrorsResponseKey: attributeErrors
        ]
        self.mockHTTPClient.stubbedCompletionResponse = attributesErrorsResponse

        let subscriberAttributesByKey: [String: SubscriberAttribute] = [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ]
        var receivedError: NSError?
        backend.post(receiptData: receiptData,
                     appUserID: appUserID,
                     isRestore: false,
                     productData: nil,
                     presentedOfferingIdentifier: nil,
                     observerMode: false,
                     subscriberAttributes: subscriberAttributesByKey,
                     completion: { (_, error) in
            completionCallCount += 1
            receivedError = error as NSError?
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))
        expect(receivedError).toEventuallyNot(beNil())
        guard let nonNilReceivedError = receivedError else {
            fail("missing receivedError")
            return
        }
        expect(nonNilReceivedError.successfullySynced) == true
        expect(nonNilReceivedError.subscriberAttributesErrors) == attributeErrors[Backend.RCAttributeErrorsKey]

        guard let underlyingError = (nonNilReceivedError as NSError).userInfo[NSUnderlyingErrorKey] as? NSError else {
            fail("Missing underlying error")
            return
        }

        expect(underlyingError.userInfo[NSUnderlyingErrorKey]).to(beNil())
    }

    func testPostReceiptWithSubscriberAttributesPassesErrorsToCallbackIfStatusCodeIsSuccess() {
        var completionCallCount = 0

        self.mockHTTPClient.stubbedCompletionStatusCode = .success
        let attributeErrors = [
            Backend.RCAttributeErrorsKey: ["$email": "email is not in valid format"]
        ]
        var response: [String: Any] = validSubscriberResponse
        response[Backend.RCAttributeErrorsResponseKey] = attributeErrors
        self.mockHTTPClient.stubbedCompletionResponse = response

        let subscriberAttributesByKey: [String: SubscriberAttribute] = [
            subscriberAttribute1.key: subscriberAttribute1,
            subscriberAttribute2.key: subscriberAttribute2
        ]
        var receivedError: NSError?
        backend.post(receiptData: receiptData,
                     appUserID: appUserID,
                     isRestore: false,
                     productData: nil,
                     presentedOfferingIdentifier: nil,
                     observerMode: false,
                     subscriberAttributes: subscriberAttributesByKey,
                     completion: { (_, error) in
            completionCallCount += 1
            receivedError = error as NSError?
        })

        expect(self.mockHTTPClient.invokedPerformRequestCount).toEventually(equal(1))

        expect(receivedError).toEventuallyNot(beNil())
        guard let nonNilReceivedError = receivedError else { fatalError() }
        expect(nonNilReceivedError.successfullySynced) == true
        expect(nonNilReceivedError.subscriberAttributesErrors)
        == attributeErrors[Backend.RCAttributeErrorsKey]
    }

}

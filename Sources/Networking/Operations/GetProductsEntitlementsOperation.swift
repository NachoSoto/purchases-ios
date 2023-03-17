//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  GetProductsEntitlementsOperation.swift
//
//  Created by Nacho Soto on 3/17/23.

import Foundation

final class GetProductsEntitlementsOperation: CacheableNetworkOperation {

    private let callbackCache: CallbackCache<ProductsEntitlementsCallback>

    static func createFactory(
        configuration: NetworkConfiguration,
        callbackCache: CallbackCache<ProductsEntitlementsCallback>
    ) -> CacheableNetworkOperationFactory<GetProductsEntitlementsOperation> {
        return .init({ cacheKey in
                .init(
                    configuration: configuration,
                    callbackCache: callbackCache,
                    cacheKey: cacheKey
                )
        },
                     individualizedCacheKeyPart: "")
    }

    private init(configuration: NetworkConfiguration,
                 callbackCache: CallbackCache<ProductsEntitlementsCallback>,
                 cacheKey: String) {
        self.callbackCache = callbackCache
        super.init(configuration: configuration, cacheKey: cacheKey)
    }

    override func begin(completion: @escaping () -> Void) {
        self.getResponse(completion: completion)
    }

}

private extension GetProductsEntitlementsOperation {

    func getResponse(completion: @escaping () -> Void) {
        let request = HTTPRequest(method: .get, path: .getProductsEntitlements)

        self.httpClient.perform(request) { (response: HTTPResponse<ProductsEntitlementsResponse>.Result) in
            defer {
                completion()
            }

            self.callbackCache.performOnAllItemsAndRemoveFromCache(withCacheable: self) { callbackObject in
                callbackObject.completion(response
                    .map { $0.body }
                    .mapError(BackendError.networkError)
                )
            }
        }
    }

}

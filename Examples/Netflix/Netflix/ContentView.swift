//
//  ContentView.swift
//  Netflix
//
//  Created by Nacho Soto on 5/30/23.
//

import SwiftUI
import RevenueCat

struct ContentView: View {

    var body: some View {
        Netflix()
            .task {
                Purchases.configure(
                    with: .init(withAPIKey: "VtDdmbdWBySmqJeeQUTyrNxETUVkhuaJ")
                        .with(usesStoreKit2IfAvailable: true)
                )
            }
            .debugRevenueCatOverlay()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

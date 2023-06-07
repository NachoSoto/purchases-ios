//
//  NetflixApp.swift
//  Netflix
//
//  Created by Nacho Soto on 5/30/23.
//

import SwiftUI

@main
struct NetflixApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct Netflix: View {

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
        .statusBarHidden(true)
    }

}

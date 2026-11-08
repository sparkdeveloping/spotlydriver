//
//  spotlydriverApp.swift
//  spotlydriver
//
//  Created by Denzel Nyatsanza on 6/28/26.
//

import SwiftUI

@main
struct spotlydriverApp: App {
    init() {
        DriverFirebaseBootstrap.configureIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

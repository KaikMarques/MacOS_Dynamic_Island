//
//  DynamicIslandApp.swift
//  V2-Dynamic Island
//
//  Entry point do aplicativo
//

import SwiftUI

@main
struct DynamicIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


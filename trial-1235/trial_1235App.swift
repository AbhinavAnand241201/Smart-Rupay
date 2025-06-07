//
//  trial_1235App.swift
//
import SwiftUI

@main
struct trial_1235App: App {
    // Create the store here. It will stay alive for the entire app session.
    @StateObject private var transactionStore = TransactionStore()
    
    var body: some Scene {
        WindowGroup {
            // We inject the store into the environment of our root view.
            // Any child view can now access it.
            LoginScreenView() // Or your main tab view if login is not implemented
                .environmentObject(transactionStore)
        }
    }
}

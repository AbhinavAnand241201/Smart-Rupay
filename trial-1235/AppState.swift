//
//  AppState.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 08/06/25.
//


// AppState.swift

import Foundation

// This simple object will be observed by the app's entry point
// to switch between the Login screen and the main app.
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    static let shared = AppState()
    private init() {}
}
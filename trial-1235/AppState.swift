

// AppState.swift

import Foundation

final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    static let shared = AppState()
    private init() {}
}




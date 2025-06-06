////
////  Extensions.swift
////  trial-1235
////
////  Created by ABHINAV ANAND  on 06/06/25.
////
//
//
//// File: Utils/Color+Extensions.swift
//
//import SwiftUI
//
//// By placing this extension in its own file, it is globally available
//// to every view and file in your app project.
//
//extension Color {
//    // Primary UI Colors from your design
//    static let primaryBackground = Color(hex: "#151618")
//    static let cardBackground = Color(hex: "#26292E")
//    static let primaryAccent = Color(hex: "#3AD7D5")
//    static let textPrimary = Color.white
//    static let textSecondary = Color(hex: "#A0A0A0")
//    static let warning = Color(hex: "#FF4500")
//    
//    // Initializer to accept hex strings
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

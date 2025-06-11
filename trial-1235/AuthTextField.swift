//
//  AuthTextField.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 12/06/25.
//


// In the NEW file: AuthComponents.swift

import SwiftUI

// MARK: - Auth Text Field Component
struct AuthTextField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .foregroundColor(Color.App.textSecondary)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.App.textSecondary))
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.App.textSecondary))
                }
            }
            .font(.system(size: 16, design: .rounded))
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .foregroundColor(Color.App.textPrimary)
            .tint(Color.App.accent)
        }
        .padding()
        .background(Color.App.card.opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.App.textSecondary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Social Login Button Component
struct SocialLoginButton: View {
    let iconName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.largeTitle)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.App.card.opacity(0.5))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.textSecondary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
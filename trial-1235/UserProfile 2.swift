//
//  UserProfile 2.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 12/06/25.
//


// In a NEW file: SettingsComponents.swift

import SwiftUI

// MARK: - Models
struct UserProfile {
    var fullName: String
    var email: String
    var phoneNumber: String
    var profileImageName: String
}

struct SettingIcon: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

// MARK: - Reusable UI Components

struct ProfileHeaderView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 8) {
            Image(user.profileImageName)
                .resizable().scaledToFill().frame(width: 80, height: 80).clipShape(Circle())
                .overlay(Circle().stroke(Color.App.accent.gradient, lineWidth: 2))
                .shadow(radius: 5)
            
            Text(user.fullName).font(.title2.bold()).foregroundColor(.App.textPrimary)
            Text(user.email).font(.subheadline).foregroundColor(.App.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // In file: SettingsComponents.swift
    // Inside: struct SettingsSectionView

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Slightly increased spacing
            if let title = title, !title.isEmpty {
                Text(title)
                    // --- Changes are here ---
                    .font(.headline.weight(.bold)) // Make the font bold
                    .foregroundColor(Color.App.textPrimary) // Make the text white
                    .textCase(nil) // Prevent automatic uppercasing
                    .padding(.horizontal)
            }
            VStack(spacing: 0) {
                content
            }
            .background(Color.App.card)
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

struct SettingRow<TrailingContent: View>: View {
    let icon: SettingIcon
    let title: String
    let titleColor: Color
    let value: String?
    let action: (() -> Void)?
    @ViewBuilder let trailingContent: TrailingContent

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon.name)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(icon.color.gradient)
                    .cornerRadius(8)

                Text(title).font(.body).foregroundColor(titleColor)
                Spacer()
                if let value = value {
                    Text(value).foregroundColor(.App.textSecondary)
                }
                trailingContent
                
                if TrailingContent.self == EmptyView.self && value == nil {
                     Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.App.textSecondary.opacity(0.5))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Initializers for SettingRow
extension SettingRow {
    init(icon: SettingIcon, title: String, titleColor: Color = .App.textPrimary, value: String? = nil, action: (() -> Void)? = nil) where TrailingContent == EmptyView {
        self.init(icon: icon, title: title, titleColor: titleColor, value: value, action: action) { EmptyView() }
    }

    init(icon: SettingIcon, title: String, titleColor: Color = .App.textPrimary, @ViewBuilder trailingContent: () -> TrailingContent) where TrailingContent: View {
        self.init(icon: icon, title: title, titleColor: titleColor, value: nil, action: nil, trailingContent: trailingContent)
    }
}

// MARK: - Placeholder Destination Views
struct EditInfoView_Placeholder: View { var body: some View { Text("Edit Info").font(.largeTitle) } }
struct ChangePasswordView_Placeholder: View { var body: some View { Text("Change Password") } }
struct ManageSubscriptionView_Placeholder: View { var body: some View { Text("Manage Subscription") } }
struct LoginActivityView_Placeholder: View { var body: some View { Text("Login Activity") } }
struct CurrencySelectionView_Placeholder: View { var body: some View { Text("Currency Selection") } }
struct TwoFactorAuthView_Placeholder: View { var body: some View { Text("2FA Setup") } }

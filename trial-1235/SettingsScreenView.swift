//
//  SettingsScreenView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 03/06/25.
//


import SwiftUI

// Assume Color(hex: String) extension is globally available.

struct SettingsScreenView: View {
    // State variables for toggles
    @State private var isFaceIDEnabled = true
    @State private var areNotificationsEnabled = false

    // MARK: - UI Colors (Aligned with Budgets Screen Theme)
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    // rowBackgroundColor is now applied by SettingsSectionView to the group
    let sectionHeaderColor = Color(hex: "A0A0A0")
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "8E8E93")
    let accentColorTeal = Color(hex: "3AD7D5")
    let destructiveColor = Color(hex: "FF453A")

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar (same as before)
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(mainTextColor)
                    }
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Image(systemName: "arrow.left").opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // MARK: - Account Section
                        SettingsSectionView(title: "Account") {
                            NavigationLink(destination: EditProfileView_Placeholder()) {
                                SettingRow(iconName: "person.fill", iconColor: accentColorTeal, title: "Edit Profile")
                            }
                            NavigationLink(destination: ChangePasswordView_Placeholder()) {
                                SettingRow(iconName: "lock.fill", iconColor: accentColorTeal, title: "Change Password")
                            }
                            NavigationLink(destination: PaymentMethodsView_Placeholder()) {
                                SettingRow(iconName: "creditcard.fill", iconColor: accentColorTeal, title: "Payment Methods")
                            }
                        }

                        // MARK: - Preferences Section
                        SettingsSectionView(title: "Preferences") {
                            // Row with a Toggle
                            SettingRow(iconName: "bell.fill", iconColor: accentColorTeal, title: "Notifications") {
                                Toggle("", isOn: $areNotificationsEnabled)
                                    .tint(accentColorTeal)
                            }
                            NavigationLink(destination: CurrencySelectionView_Placeholder()) {
                                SettingRow(iconName: "dollarsign.circle.fill", iconColor: accentColorTeal, title: "Currency", value: "USD")
                            }
                            // Row with a Toggle
                            SettingRow(iconName: "faceid", iconColor: accentColorTeal, title: "Enable Face ID") {
                                Toggle("", isOn: $isFaceIDEnabled)
                                    .tint(accentColorTeal)
                            }
                        }
                        
                        // MARK: - Security & Legal Section
                        SettingsSectionView(title: "Security & Legal") {
                            NavigationLink(destination: TwoFactorAuthView_Placeholder()) {
                                SettingRow(iconName: "shield.lefthalf.filled", iconColor: accentColorTeal, title: "Two-Factor Authentication")
                            }
                            // Action row that looks like navigation (added chevron)
                            SettingRow(iconName: "doc.text.fill", iconColor: accentColorTeal, title: "Privacy Policy", showsDisclosureChevron: true, action: { print("Privacy Policy Tapped") })
                            SettingRow(iconName: "checkmark.shield.fill", iconColor: accentColorTeal, title: "Terms of Service", showsDisclosureChevron: true, action: { print("Terms Tapped") })
                        }

                        // MARK: - App Section
                        SettingsSectionView(title: "Application") {
                            SettingRow(iconName: "info.circle.fill", iconColor: accentColorTeal, title: "App Version", value: "1.0.0 (Smart-Rupay)") // Informational
                            // Action row that looks like navigation
                            SettingRow(iconName: "star.fill", iconColor: accentColorTeal, title: "Rate Smart-Rupay", showsDisclosureChevron: true, action: {
                                print("Rate App Tapped")
                            })
                        }
                        
                        // MARK: - Log Out Section
                        SettingsSectionView {
                            SettingRow(iconName: "arrow.right.square.fill", iconColor: destructiveColor, title: "Log Out", titleColor: destructiveColor, action: {
                                print("Log Out Tapped")
                            })
                        }
                        .padding(.top, 10)

                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Reusable Setting Row Components

struct SettingsSectionView<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = title, !title.isEmpty {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "A0A0A0"))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            VStack(spacing: 1) { // Use 1 for a thin line effect if rows don't have their own bg
                content
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.18)) // Group background
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
     init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
}

struct SettingRow<TrailingContent: View>: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let titleColor: Color
    let value: String?
    let action: (() -> Void)?
    @ViewBuilder let trailingContent: TrailingContent

    init(iconName: String, iconColor: Color, title: String, titleColor: Color = .white, value: String? = nil, action: (() -> Void)? = nil, @ViewBuilder trailingContent: () -> TrailingContent) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.titleColor = titleColor
        self.value = value
        self.action = action
        self.trailingContent = trailingContent()
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 15) {
                Image(systemName: iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24, alignment: .center)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "A0A0A0"))
                }
                
                trailingContent
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 15)
            .contentShape(Rectangle()) // Ensure the whole area is tappable for the button
        }
        // Removed the problematic .disabled() modifier
        // If action is nil, tapping the Button does nothing, which is fine.
        // NavigationLink and Toggle will handle their own interactions.
    }
}

// In SettingsScreenView.swift
// In SettingsScreenView.swift

// Convenience initializers for SettingRow
extension SettingRow {
    // For rows that are purely informational or simple actions without custom trailing UI
    init(iconName: String, iconColor: Color, title: String, titleColor: Color = .white, value: String? = nil, action: (() -> Void)? = nil) where TrailingContent == EmptyView {
        self.init(iconName: iconName, iconColor: iconColor, title: title, titleColor: titleColor, value: value, action: action) {
            EmptyView()
        }
    }

    // For action rows that might display a disclosure chevron
    // MODIFIED: Constraint changed to AnyView, and closure wrapped in AnyView
    init(iconName: String, iconColor: Color, title: String, titleColor: Color = .white, value: String? = nil, showsDisclosureChevron: Bool, action: @escaping () -> Void) where TrailingContent == AnyView {
        self.init(iconName: iconName, iconColor: iconColor, title: title, titleColor: titleColor, value: value, action: action) {
            // Wrap the conditional content in AnyView to erase its specific type
            AnyView(
                Group { // Group helps if AnyView expects a single expression sometimes
                    if showsDisclosureChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "A0A0A0").opacity(0.7))
                    } else {
                        EmptyView()
                    }
                }
            )
        }
    }
}
// MARK: - Placeholder Destination Views (same as before)
struct EditProfileView_Placeholder: View { var body: some View { Text("Edit Profile Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct ChangePasswordView_Placeholder: View { var body: some View { Text("Change Password Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct PaymentMethodsView_Placeholder: View { var body: some View { Text("Payment Methods Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct CurrencySelectionView_Placeholder: View { var body: some View { Text("Currency Selection Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct TwoFactorAuthView_Placeholder: View { var body: some View { Text("2FA Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }

// MARK: - Preview
struct SettingsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsScreenView()
        }
    }
}

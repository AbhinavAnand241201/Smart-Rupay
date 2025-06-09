import SwiftUI

struct SettingsScreenView: View {

    @State private var isFaceIDEnabled = true
    @State private var areNotificationsEnabled = false


    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)

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


                        SettingsSectionView(title: "Preferences") {
                            SettingRow(iconName: "bell.fill", iconColor: accentColorTeal, title: "Notifications") {
                                Toggle("", isOn: $areNotificationsEnabled)
                                    .tint(accentColorTeal)
                            }
                            NavigationLink(destination: CurrencySelectionView_Placeholder()) {
                                SettingRow(iconName: "dollarsign.circle.fill", iconColor: accentColorTeal, title: "Currency", value: "USD")
                            }
                            SettingRow(iconName: "faceid", iconColor: accentColorTeal, title: "Enable Face ID") {
                                Toggle("", isOn: $isFaceIDEnabled)
                                    .tint(accentColorTeal)
                            }
                        }
                        

                        SettingsSectionView(title: "Security & Legal") {
                            NavigationLink(destination: TwoFactorAuthView_Placeholder()) {
                                SettingRow(iconName: "shield.lefthalf.filled", iconColor: accentColorTeal, title: "Two-Factor Authentication")
                            }

                            SettingRow(iconName: "doc.text.fill", iconColor: accentColorTeal, title: "Privacy Policy", showsDisclosureChevron: true, action: { print("Privacy Policy Tapped") })
                            SettingRow(iconName: "checkmark.shield.fill", iconColor: accentColorTeal, title: "Terms of Service", showsDisclosureChevron: true, action: { print("Terms Tapped") })
                        }


                        SettingsSectionView(title: "Application") {
                            SettingRow(iconName: "info.circle.fill", iconColor: accentColorTeal, title: "App Version", value: "1.0.0 (Smart-Rupay)")
                            SettingRow(iconName: "star.fill", iconColor: accentColorTeal, title: "Rate Smart-Rupay", showsDisclosureChevron: true, action: {
                                print("Rate App Tapped")
                            })
                        }
                        

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
            VStack(spacing: 1) {
                content
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.18))
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
            .contentShape(Rectangle())
        }

    }
}

extension SettingRow {

    init(iconName: String, iconColor: Color, title: String, titleColor: Color = .white, value: String? = nil, action: (() -> Void)? = nil) where TrailingContent == EmptyView {
        self.init(iconName: iconName, iconColor: iconColor, title: title, titleColor: titleColor, value: value, action: action) {
            EmptyView()
        }
    }



    init(iconName: String, iconColor: Color, title: String, titleColor: Color = .white, value: String? = nil, showsDisclosureChevron: Bool, action: @escaping () -> Void) where TrailingContent == AnyView {
        self.init(iconName: iconName, iconColor: iconColor, title: title, titleColor: titleColor, value: value, action: action) {

            AnyView(
                Group {
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

struct EditProfileView_Placeholder: View { var body: some View { Text("Edit Profile Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct ChangePasswordView_Placeholder: View { var body: some View { Text("Change Password Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct PaymentMethodsView_Placeholder: View { var body: some View { Text("Payment Methods Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct CurrencySelectionView_Placeholder: View { var body: some View { Text("Currency Selection Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct TwoFactorAuthView_Placeholder: View { var body: some View { Text("2FA Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }


struct SettingsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsScreenView()
        }
    }
}


// In file: SettingsScreenView.swift

import SwiftUI

struct SettingsScreenView: View {
    @State private var isFaceIDEnabled = true
    @State private var areNotificationsEnabled = false
    
    // Using a sample user profile for the demo
    private let user = UserProfile(
        fullName: "Ethan Carter",
        email: "ethan.carter@example.com",
        phoneNumber: "+91 98765 43210",
        profileImageName: "ab1"
    )

    var body: some View {
        NavigationView {
            ZStack {
                Color.App.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ProfileHeaderView(user: user)
                        
                        SettingsSectionView(title: "Account") {
                            NavigationLink(destination: ProfileSettingsScreenView(userProfile: user)) {
                                SettingRow(icon: .init(name: "person.fill", color: .App.accentBlue), title: "Profile & Account")
                            }
                            NavigationLink(destination: ManageSubscriptionView_Placeholder()) {
                                SettingRow(icon: .init(name: "creditcard.fill", color: .App.accent), title: "Manage Subscription")
                            }
                        }
                        
                        SettingsSectionView(title: "Preferences") {
                            SettingRow(icon: .init(name: "bell.fill", color: .App.accentPink), title: "Notifications") {
                                Toggle("", isOn: $areNotificationsEnabled).tint(Color.App.accent)
                            }
                            NavigationLink(destination: CurrencySelectionView_Placeholder()) {
                                SettingRow(icon: .init(name: "indianrupeesign.circle.fill", color: .App.accentGreen), title: "Currency", value: "INR (₹)")
                            }
                        }
                        
                        SettingsSectionView {
                            SettingRow(icon: .init(name: "arrow.right.square.fill", color: .App.accentPink), title: "Log Out", titleColor: .App.accentPink, action: { print("Log Out Tapped") })
                        }
                    }
                    .padding(.vertical)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 35 ))
                        .fontWeight(.heavy) // You can use .bold, .semibold, or .heavy
                        .foregroundColor(.white)
                }
            }
            
        }
    }
}

struct SettingsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreenView()
    }
}



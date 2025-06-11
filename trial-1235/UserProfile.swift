// In file: ProfileSettingsScreenView.swift

import SwiftUI

struct ProfileSettingsScreenView: View {
    // This view now receives the user profile data
    @State var userProfile: UserProfile

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    ProfileHeaderView(user: userProfile)
                    
                    SettingsSectionView(title: "Personal Information") {
                        NavigationLink(destination: EditInfoView_Placeholder()) {
                            SettingRow(icon: .init(name: "person.text.rectangle.fill", color: .App.accentBlue), title: "Full Name", value: userProfile.fullName)
                        }
                        NavigationLink(destination: EditInfoView_Placeholder()) {
                            SettingRow(icon: .init(name: "envelope.fill", color: .App.accentBlue), title: "Email Address", value: userProfile.email)
                        }
                        NavigationLink(destination: EditInfoView_Placeholder()) {
                            SettingRow(icon: .init(name: "phone.fill", color: .App.accentBlue), title: "Phone Number", value: userProfile.phoneNumber)
                        }
                    }
                    
                    SettingsSectionView(title: "Security") {
                        NavigationLink(destination: ChangePasswordView_Placeholder()) {
                            SettingRow(icon: .init(name: "lock.shield.fill", color: .App.accentGreen), title: "Change Password")
                        }
                        NavigationLink(destination: TwoFactorAuthView_Placeholder()) {
                            SettingRow(icon: .init(name: "2.circle.fill", color: .App.accentGreen), title: "Two-Factor Authentication")
                        }
                    }

                    SettingsSectionView {
                        SettingRow(icon: .init(name: "trash.fill", color: .App.accentPink), title: "Delete Account", titleColor: .App.accentPink, action: {
                            print("Delete Account tapped")
                        })
                    }
                }
                .padding(.vertical)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile & Account")
                        .fontWeight(.bold) // You can use .bold, .semibold, or .heavy
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct ProfileSettingsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsScreenView(userProfile: UserProfile(
            fullName: "Ethan Carter",
            email: "ethan.carter@example.com",
            phoneNumber: "+91 98765 43210",
            profileImageName: "ab1"
        ))
    }
}

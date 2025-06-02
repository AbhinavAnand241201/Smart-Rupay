//
//  UserProfile.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 03/06/25.
//


import SwiftUI

// Assume Color(hex: String) extension is globally available.
// Assume SettingsSectionView and SettingRow (or similar adapted versions) are available or will be defined.
// For simplicity, I'll redefine a slightly adapted SettingRow if needed for this context.

// MARK: - User Profile Data Model (Example)
struct UserProfile {
    var fullName: String
    var email: String
    var phoneNumber: String
    var profileImageName: String // Name of the image asset
    // Add other fields like dateOfBirth, address, etc.
}

struct ProfileSettingsScreenView: View {
    @State private var userProfile = UserProfile(
        fullName: "Ethan Carter", // Example Data
        email: "ethan.carter@example.com",
        phoneNumber: "+1 (555) 123-4567",
        profileImageName: "ab1" // Using the placeholder from your previous files
    )
    
    // MARK: - UI Colors (Consistent with App Theme)
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let sectionBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")
    let accentColorTeal = Color(hex: "3AD7D5")
    let destructiveColor = Color(hex: "FF453A") // iOS system red

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(mainTextColor)
                    }
                    Spacer()
                    Text("Profile & Account")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Image(systemName: "arrow.left").opacity(0) // Balance
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 25) {
                        // MARK: - Profile Header
                        ProfileHeaderView(
                            imageName: userProfile.profileImageName,
                            userName: userProfile.fullName,
                            userEmail: userProfile.email,
                            accentColor: accentColorTeal
                        ) {
                            print("Change profile picture tapped")
                            // Action to change profile picture
                        }
                        .padding(.bottom, 10)

                        // MARK: - Personal Information Section
                        ProfileSectionView(title: "Personal Information") {
                            NavigationLink(destination: EditInfoView_Placeholder(field: "Full Name", currentValue: $userProfile.fullName)) {
                                ProfileDetailRow(iconName: "person.text.rectangle.fill", iconColor: accentColorTeal, label: "Full Name", value: userProfile.fullName)
                            }
                            NavigationLink(destination: EditInfoView_Placeholder(field: "Email Address", currentValue: $userProfile.email)) {
                                ProfileDetailRow(iconName: "envelope.fill", iconColor: accentColorTeal, label: "Email Address", value: userProfile.email)
                            }
                            NavigationLink(destination: EditInfoView_Placeholder(field: "Phone Number", currentValue: $userProfile.phoneNumber)) {
                                ProfileDetailRow(iconName: "phone.fill", iconColor: accentColorTeal, label: "Phone Number", value: userProfile.phoneNumber)
                            }
                        }

                        // MARK: - Account Management Section
                        ProfileSectionView(title: "Account Management") {
                            NavigationLink(destination: ChangePasswordView_Placeholder()) { // Re-use from general settings if identical
                                ProfileDetailRow(iconName: "lock.shield.fill", iconColor: accentColorTeal, label: "Change Password")
                            }
                             NavigationLink(destination: ManageSubscriptionView_Placeholder()) {
                                ProfileDetailRow(iconName: "creditcard.circle.fill", iconColor: accentColorTeal, label: "Manage Subscription")
                            }
                        }
                        
                        // MARK: - Security & Data
                        ProfileSectionView(title: "Security & Data") {
                            NavigationLink(destination: LoginActivityView_Placeholder()) {
                                ProfileDetailRow(iconName: "list.star", iconColor: accentColorTeal, label: "Login Activity")
                            }
                            ProfileDetailRow(iconName: "arrow.down.doc.fill", iconColor: accentColorTeal, label: "Export My Data", action: {
                                print("Export data tapped")
                            })
                        }


                        // MARK: - Delete Account Section
                        ProfileSectionView { // Section without a title for distinct actions
                            ProfileDetailRow(iconName: "trash.fill", iconColor: destructiveColor, label: "Delete Account", labelColor: destructiveColor, action: {
                                print("Delete Account tapped")
                                // Show confirmation alert
                            })
                        }
                        .padding(.top, 10) // Add some space before delete

                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Reusable Profile Components

struct ProfileHeaderView: View {
    let imageName: String
    let userName: String
    let userEmail: String
    let accentColor: Color
    let onImageTap: () -> Void
    
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")


    var body: some View {
        VStack(spacing: 12) {
            Image(imageName) // Assuming image is in assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .overlay(alignment: .bottomTrailing) {
                    Button(action: onImageTap) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(accentColor)
                            .background(Circle().fill(Color(red: 0.15, green: 0.16, blue: 0.18))) // Background for icon
                            .offset(x: 5, y: 5) // Adjust offset as needed
                    }
                }
                .padding(.bottom, 5)

            Text(userName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(mainTextColor)
            Text(userEmail)
                .font(.system(size: 16))
                .foregroundColor(secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct ProfileSectionView<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content
    
    let sectionBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let sectionHeaderColor = Color(hex: "A0A0A0")


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = title, !title.isEmpty {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(sectionHeaderColor)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            VStack(spacing: 1) { // Use 1 for a thin line effect if rows don't have their own bg
                content
            }
            .background(sectionBackgroundColor)
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
}

struct ProfileDetailRow: View {
    let iconName: String
    let iconColor: Color
    let label: String
    var labelColor: Color = .white
    let value: String?
    let action: (() -> Void)?

    // Initializer for rows with a value (often for NavigationLink content)
    init(iconName: String, iconColor: Color, label: String, labelColor: Color = .white, value: String) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.label = label
        self.labelColor = labelColor
        self.value = value
        self.action = nil
    }

    // Initializer for action rows or NavigationLinks without an explicit value shown
    init(iconName: String, iconColor: Color, label: String, labelColor: Color = .white, action: (() -> Void)? = nil) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.label = label
        self.labelColor = labelColor
        self.value = nil
        self.action = action
    }
    
    let mainTextColor = Color.white
    let secondaryTextColor = Color(hex: "A0A0A0")


    var body: some View {
        Group { // Use Group to allow conditional execution of action
            if let action = action {
                Button(action: action) {
                    rowContent
                }
            } else {
                rowContent // For NavigationLink, the link itself provides action
            }
        }
    }

    private var rowContent: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 24, alignment: .center)

            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(labelColor)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(secondaryTextColor)
            }
            
            // Chevron is automatically added by NavigationLink
            // If it's an action row that should look like navigation, add chevron manually:
            if action != nil && value == nil { // Simple action row that might imply navigation
                 Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(secondaryTextColor.opacity(0.7))
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 15)
        .contentShape(Rectangle()) // Make sure the whole area is tappable if it's a button
    }
}


// MARK: - Placeholder Destination Views
struct EditInfoView_Placeholder: View {
    let field: String
    @Binding var currentValue: String
    @Environment(\.presentationMode) var presentationMode
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let mainTextColor = Color.white

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()
            VStack {
                Text("Edit \(field)")
                    .font(.largeTitle).foregroundColor(mainTextColor)
                TextField(field, text: $currentValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Save") { presentationMode.wrappedValue.dismiss() }
                    .padding()
                Spacer()
            }
            .navigationTitle("Edit \(field)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct ManageSubscriptionView_Placeholder: View { var body: some View { Text("Manage Subscription Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
struct LoginActivityView_Placeholder: View { var body: some View { Text("Login Activity Screen").foregroundColor(.white).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.08, green: 0.09, blue: 0.10).ignoresSafeArea()) } }
// ChangePasswordView_Placeholder can be reused from general Settings if it's the same.


// MARK: - Preview
struct ProfileSettingsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettingsScreenView()
        }
    }
}
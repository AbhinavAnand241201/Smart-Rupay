//
//  LoginScreenView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 02/06/25.
//


import SwiftUI

// Assume Color(hex: String) extension is globally available.
// Assume CustomStyledTextField struct (updated to accept color parameters) is globally available.

struct LoginScreenView: View {
    @State private var email = ""
    @State private var password = ""

    // MARK: - UI Colors (Aligned with Budgets Screen Theme)
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let textFieldBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18) // Consistent dark element bg
    let placeholderTextColor = Color(hex: "A0A0A0") // Consistent subtitle gray
    let mainTextColor = Color.white
    let accentColorTeal = Color(hex: "3AD7D5") // Primary button color from Budgets screen
    // For Google button, use a less prominent dark background from the theme
    let secondaryButtonBackgroundColor = Color(red: 0.20, green: 0.21, blue: 0.23) // Similar to filter pills or a darker card
    let linkTextColor = Color.white // White for links, or could use accentColorTeal
    let orTextColor = Color(hex: "A0A0A0")
    let inputTextColor = Color.white

    var body: some View {
        ZStack {
            screenBackgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Navigation Bar
                HStack {
                    Spacer()
                    Text("Smart-Rupay")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Button(action: {
                        print("Help button tapped")
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(mainTextColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Welcome Header
                        Text("Welcome to Smart-Rupay")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(mainTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.bottom, 30)

                        // MARK: - Input Fields
                        CustomStyledTextField(
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            backgroundColor: textFieldBackgroundColor,
                            placeholderColor: placeholderTextColor,
                            textColor: inputTextColor
                        )

                        VStack(alignment: .trailing, spacing: 8) {
                            CustomStyledTextField(
                                placeholder: "Password",
                                text: $password,
                                isSecure: true,
                                backgroundColor: textFieldBackgroundColor,
                                placeholderColor: placeholderTextColor,
                                textColor: inputTextColor
                            )

                            Button(action: {
                                print("Forgot Password tapped")
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(linkTextColor) // Changed from previous linkTextColor
                            }
                        }

                        // MARK: - Log In Button
                        Button(action: {
                            print("Login tapped with Email: \(email), Pass: \(password)")
                        }) {
                            Text("Log In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white) // Text on teal button should be white or dark for contrast
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(accentColorTeal)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)

                        // MARK: - "Or" Separator
                        Text("Or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(orTextColor)
                            .padding(.vertical, 15)

                        // MARK: - Sign up with Google Button
                        Button(action: {
                            print("Sign up with Google tapped")
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20))
                                Text("Sign up with Google")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(secondaryButtonBackgroundColor)
                            .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 20)

                    }
                    .padding(.horizontal, 25)

                }
                
                Spacer()

                // MARK: - Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(placeholderTextColor) // Use placeholder color for less emphasis
                    Button(action: {
                        print("Sign Up link tapped")
                        // Add navigation to Sign Up Screen
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(linkTextColor) // Or accentColorTeal
                    }
                }
                .padding(.bottom, (UIApplication.shared.connectedScenes
                                     .compactMap { $0 as? UIWindowScene }
                                     .first?.windows.first?.safeAreaInsets.bottom ?? 0) + 15)
                .padding(.top, 10)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Preview (Login Screen)
struct LoginScreenView_Previews_Themed: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}
// In file: LoginScreenView.swift

import SwiftUI

struct LoginScreenView: View {
    // MARK: - Properties
    // All original state and logic are preserved
    @StateObject private var appState = AppState.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpPresented = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // A more dynamic and visually interesting background
                LinearGradient(
                    gradient: Gradient(colors: [Color.App.background, Color(hex: "#1C252E")]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                // Adding a subtle shape for more visual flair
                Circle()
                    .fill(Color.App.accent.opacity(0.2))
                    .blur(radius: 100)
                    .offset(x: -150, y: -250)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // MARK: - Header
                    // Redesigned header with an icon for stronger branding
                    VStack {
                        Image(systemName: "indianrupeesign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.App.accent, .white],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.App.accent.opacity(0.5), radius: 10)
                        
                        Text("Smart-Rupay")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color.App.textPrimary)
                    }
                    .padding(.bottom, 40)

                    // MARK: - Form Fields
                    // Using a new, enhanced text field style for a premium feel
                    VStack(spacing: 16) {
                        AuthTextField(
                            iconName: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        AuthTextField(
                            iconName: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true
                        )
                    }
                    
                    // MARK: - Log In Button
                    // A more visually impactful primary button
                    Button(action: {
                        appState.isLoggedIn = true
                    }) {
                        Text("Log In")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.App.accent)
                            .cornerRadius(16)
                            .shadow(color: Color.App.accent.opacity(0.4), radius: 10, y: 5)
                    }
                    .padding(.top, 20)

                    // MARK: - Alternative Logins
                    // A common modern pattern that enhances user experience
                    HStack {
                        VStack { Divider().background(Color.App.textSecondary.opacity(0.5)) }
                        Text("OR").foregroundColor(Color.App.textSecondary)
                        VStack { Divider().background(Color.App.textSecondary.opacity(0.5)) }
                    }
                    .padding(.vertical, 15)
                    
                    HStack(spacing: 20) {
                        SocialLoginButton(iconName: "g.circle.fill", color: .red) { /* Google Login Action */ }
                        SocialLoginButton(iconName: "apple.logo", color: .white) { /* Apple Login Action */ }
                    }

                    Spacer()
                    Spacer()

                    // MARK: - Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(Color.App.textSecondary)
                        Button("Sign Up") {
                            isSignUpPresented = true
                        }
                        .fontWeight(.bold)
                        .foregroundColor(Color.App.accent)
                    }
                }
                .padding(.horizontal, 30)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isSignUpPresented) {
                // SignUpScreenView() // This will present your sign-up screen
            }
        }
    }
}

// MARK: - Preview
struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}

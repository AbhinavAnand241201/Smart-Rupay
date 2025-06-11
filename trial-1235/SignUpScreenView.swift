// In file: SignUpScreenView.swift

import SwiftUI

struct SignUpScreenView: View {
    // MARK: - Properties
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Body
    var body: some View {
        ZStack {
            // Consistent dynamic background from the Login screen
            LinearGradient(
                gradient: Gradient(colors: [Color.App.background, Color(hex: "#1C252E")]),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            Circle()
                .fill(Color.App.accentGreen.opacity(0.2))
                .blur(radius: 100)
                .offset(x: 150, y: -250)

            VStack(spacing: 0) {
                // Custom navigation bar for a seamless look
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.medium))
                            .foregroundColor(Color.App.textSecondary)
                    }
                    Spacer()
                }
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // MARK: - Header
                        VStack {
                            Text("Create Your Account")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color.App.textPrimary)
                            
                            Text("Join Smart-Rupay to take control of your finances.")
                                .font(.subheadline)
                                .foregroundColor(Color.App.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 30)

                        // MARK: - Form Fields
                        VStack(spacing: 16) {
                            // Reusing the same enhanced text field style from the Login screen
                            AuthTextField(iconName: "person.fill", placeholder: "Full Name", text: $fullName)
                            AuthTextField(iconName: "envelope.fill", placeholder: "Email", text: $email, keyboardType: .emailAddress)
                            AuthTextField(iconName: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                            AuthTextField(iconName: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                        }
                        
                        // MARK: - Sign Up Button
                        Button(action: {
                            print("Sign Up tapped with Email: \(email), FullName: \(fullName)")
                            // Your registration logic would go here
                        }) {
                            Text("Create Account")
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
                        HStack {
                            VStack { Divider().background(Color.App.textSecondary.opacity(0.5)) }
                            Text("OR").foregroundColor(Color.App.textSecondary)
                            VStack { Divider().background(Color.App.textSecondary.opacity(0.5)) }
                        }
                        .padding(.vertical, 15)
                        
                        HStack(spacing: 20) {
                            SocialLoginButton(iconName: "g.circle.fill", color: .red) { /* Google Sign Up Action */ }
                            SocialLoginButton(iconName: "apple.logo", color: .white) { /* Apple Sign Up Action */ }
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
}


// MARK: - Preview
struct SignUpScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreenView()
    }
}


import SwiftUI

// Assume Color(hex: String) extension is globally available.
// Assume CustomStyledTextField struct (updated to accept color parameters) is globally available.

struct SignUpScreenView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // MARK: - UI Colors (Aligned with Budgets Screen Theme)
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let textFieldBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let placeholderTextColor = Color(hex: "A0A0A0")
    let mainTextColor = Color.white
    let accentColorTeal = Color(hex: "3AD7D5")
    let secondaryButtonBackgroundColor = Color(red: 0.20, green: 0.21, blue: 0.23)
    let linkTextColor = Color.white // Or accentColorTeal
    let orTextColor = Color(hex: "A0A0A0")
    let inputTextColor = Color.white
    
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
                    Text("Create Account")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Image(systemName: "questionmark.circle.fill") // Placeholder for balance
                         .font(.system(size: 22))
                         .foregroundColor(mainTextColor)
                         .opacity(0) // To balance the back arrow
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Welcome Header
                        Text("Join Smart-Rupay")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(mainTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 15)
                            .padding(.bottom, 25)

                        // MARK: - Input Fields
                        CustomStyledTextField(
                            placeholder: "Full Name",
                            text: $fullName,
                            backgroundColor: textFieldBackgroundColor,
                            placeholderColor: placeholderTextColor,
                            textColor: inputTextColor
                        )

                        CustomStyledTextField(
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            backgroundColor: textFieldBackgroundColor,
                            placeholderColor: placeholderTextColor,
                            textColor: inputTextColor
                        )

                        CustomStyledTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            backgroundColor: textFieldBackgroundColor,
                            placeholderColor: placeholderTextColor,
                            textColor: inputTextColor
                        )

                        CustomStyledTextField(
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            isSecure: true,
                            backgroundColor: textFieldBackgroundColor,
                            placeholderColor: placeholderTextColor,
                            textColor: inputTextColor
                        )

                        // MARK: - Sign Up Button
                        Button(action: {
                            print("Sign Up tapped with Email: \(email), FullName: \(fullName)")
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white) // Text on teal button
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

                // MARK: - Log In Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(placeholderTextColor)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Log In")
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
        .navigationBarHidden(true)
    }
}

// MARK: - Preview (Sign Up Screen)
struct SignUpScreenView_Previews_Themed: PreviewProvider {
    static var previews: some View {
        NavigationView { // Good to preview with NavigationView for the back button
            SignUpScreenView()
        }
    }
}

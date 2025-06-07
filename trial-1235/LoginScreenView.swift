import SwiftUI

struct LoginScreenView: View {
    // This state is managed by the App's root to switch views.
    @StateObject private var appState = AppState.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpPresented = false

    // MARK: - UI Colors
    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let textFieldBackgroundColor = Color(red: 0.15, green: 0.16, blue: 0.18)
    let placeholderTextColor = Color(hex: "A0A0A0")
    let mainTextColor = Color.white
    let accentColorTeal = Color(hex: "3AD7D5")
    let secondaryButtonBackgroundColor = Color(red: 0.20, green: 0.21, blue: 0.23)
    let linkTextColor = Color.white
    let orTextColor = Color(hex: "A0A0A0")
    let inputTextColor = Color.white

    var body: some View {
        NavigationView { // Wrap in NavigationView to allow for the sheet presentation
            ZStack {
                screenBackgroundColor.ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                    Text("Smart-Rupay")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(mainTextColor)
                        .padding(.bottom, 30)

                    CustomStyledTextField(
                        placeholder: "Email",
                        text: $email,
                        keyboardType: .emailAddress
                    )

                    CustomStyledTextField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                    
                    // MARK: - Log In Button
                    Button(action: {
                        // In a real app, you would verify email and password here.
                        // FIXED: This now correctly tells the rest of the app to proceed.
                        appState.isLoggedIn = true
                    }) {
                        Text("Log In")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(accentColorTeal)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)

                    Spacer()
                    Spacer()

                    // MARK: - Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(placeholderTextColor)
                        Button("Sign Up") {
                            isSignUpPresented = true
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(linkTextColor)
                    }
                }
                .padding(.horizontal, 25)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isSignUpPresented) {
                // This would present the SignUpScreenView you provided
                // SignUpScreenView()
            }
        }
    }
}

// FIXED: This reusable component is now defined once and correctly used.
struct CustomStyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    let backgroundColor: Color = Color(red: 0.15, green: 0.16, blue: 0.18)
    let placeholderColor: Color = Color(hex: "A0A0A0")
    let textColor: Color = Color.white

    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(placeholderColor))
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(placeholderColor))
            }
        }
        .font(.system(size: 16, design: .rounded))
        .keyboardType(keyboardType)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .foregroundColor(textColor)
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}



// MARK: - Preview (Login Screen)
struct LoginScreenView_Previews_Themed: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}

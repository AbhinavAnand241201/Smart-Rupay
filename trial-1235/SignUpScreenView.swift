import SwiftUI

struct SignUpScreenView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    let screenBackgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let mainTextColor = Color.white
    let accentColorTeal = Color(hex: "3AD7D5")
    let secondaryButtonBackgroundColor = Color(red: 0.20, green: 0.21, blue: 0.23)
    let linkTextColor = Color.white
    let orTextColor = Color(hex: "A0A0A0")
    
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
                    Text("Create Account")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainTextColor)
                    Spacer()
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(mainTextColor)
                        .opacity(0)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Join Smart-Rupay")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(mainTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 15)
                            .padding(.bottom, 25)

                        CustomStyledTextField(
                            placeholder: "Full Name",
                            text: $fullName
                        )

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

                        CustomStyledTextField(
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            isSecure: true
                        )

                        Button(action: {
                            print("Sign Up tapped with Email: \(email), FullName: \(fullName)")
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(accentColorTeal)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)

                        Text("Or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(orTextColor)
                            .padding(.vertical, 15)

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

                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(orTextColor)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Log In")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(linkTextColor)
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

struct SignUpScreenView_Previews_Themed: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpScreenView()
        }
    }
}

import SwiftUI

struct SplashScreenView: View {
    @State private var circleSize: CGFloat = 80
    @State private var circleOpacity: Double = 1.0
    @State private var textOpacity: Double = 0.0

    let backgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let accentColorTeal = Color(hex: "3AD7D5")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack {
                ZStack {
                    Circle()
                        .fill(accentColorTeal)
                        .frame(width: circleSize, height: circleSize)
                        .opacity(circleOpacity)

                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.black)
                        .opacity(circleOpacity)
                }
                
                Text("Smart-Rupay")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(textOpacity)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            animateSplashScreen()
        }
    }

    func animateSplashScreen() {
        withAnimation(.easeIn(duration: 0.8)) {
            textOpacity = 1.0
        }

        withAnimation(.easeIn(duration: 1.2).delay(1.0)) {
            circleSize = UIScreen.main.bounds.size.height * 2
            circleOpacity = 0
        }
    }
}

#Preview {
    SplashScreenView()
}

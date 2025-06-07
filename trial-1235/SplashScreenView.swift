//
//  SplashScreenView.swift
//  trial-1235
//
//  Created by ABHINAV ANAND  on 08/06/25.

//

import SwiftUI

struct SplashScreenView: View {
    // Animation state variables
    @State private var circleSize: CGFloat = 80
    @State private var circleOpacity: Double = 1.0
    @State private var textOpacity: Double = 0.0

    // App Theme Colors
    let backgroundColor = Color(red: 0.08, green: 0.09, blue: 0.10)
    let accentColorTeal = Color(hex: "3AD7D5")

    var body: some View {
        ZStack {
            // Use the app's main dark background
            backgroundColor.ignoresSafeArea()

            VStack {
                ZStack {
                    // The expanding circle
                    Circle()
                        .fill(accentColorTeal)
                        .frame(width: circleSize, height: circleSize)
                        .opacity(circleOpacity)

                    // Your app's icon or logo
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.black)
                        .opacity(circleOpacity)
                }
                
                // App Name Text that fades in
                Text("Smart-Rupay")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(textOpacity)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            // Start animations when the view appears
            animateSplashScreen()
        }
    }

    func animateSplashScreen() {
        // First animation: Fade in the text
        withAnimation(.easeIn(duration: 0.8)) {
            textOpacity = 1.0
        }

        // Second animation: Expand the circle to reveal the next screen
        // This starts after a delay to let the user see the logo
        withAnimation(.easeIn(duration: 1.2).delay(1.0)) {
            // Expand circle to be larger than the screen
            circleSize = UIScreen.main.bounds.size.height * 2
            circleOpacity = 0 // Fade out the logo inside the circle
        }
    }
}

#Preview {
    SplashScreenView()
}

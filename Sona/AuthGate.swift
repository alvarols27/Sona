//
//  AuthGate.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

struct AuthGate: View {
    @State private var showLogin = true

    var body: some View {
        ZStack {
            // Background colour
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.00, blue: 0.15),
                    Color(red: 0.24, green: 0.00, blue: 0.46)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Picker("", selection: $showLogin) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }
                .pickerStyle(.segmented)
                .background(Color.pink.opacity(0.2))
                .cornerRadius(20)
                .padding()
                .accentColor(.pink)

                if showLogin {
                    LoginView()
                        .transition(.opacity)
                } else {
                    RegisterView()
                        .transition(.opacity)
                }
            }
        }
    }
}

#Preview {
    AuthGate()
}

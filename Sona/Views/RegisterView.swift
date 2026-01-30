//
//  RegisterView.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var errorMessage: String?
    @StateObject private var auth = AuthService.shared
 
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
                Text("Create Account")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                VStack(spacing: 20) {
                    // Email field
                    TextField("", text: $email, prompt: Text("Enter Email").foregroundColor(.white.opacity(0.6)))
                    
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .foregroundColor(.white)
                    
                    // Password field
                    SecureField("", text: $password, prompt: Text("Password (Min 6 chars)").foregroundColor(.white.opacity(0.6)))
                    
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .foregroundColor(.white)
                    
                    // Display Name field
                    TextField("", text: $displayName, prompt: Text("Enter Display Name")
                        .foregroundColor(.white.opacity(0.6)))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .foregroundColor(.white)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .padding(.horizontal)
                    }
                    
                    // Sign Up button
                    Button("Sign Up") {
                        print("Sign up clicked")

                        guard Validators.isEmailValid(email) else {
                            self.errorMessage = "Invalid Email"
                            return
                        }

                        guard Validators.isValidPassword(password) else {
                            self.errorMessage = "Invalid Password"
                            return
                        }

                        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
                            self.errorMessage = "Display name is required"
                            return
                        }

                        auth.signUp(email: email, password: password, displayName: displayName) { result in
                            switch result {
                            case .success:
                                self.errorMessage = nil
                            case .failure(let failure):
                                self.errorMessage = failure.localizedDescription
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple.opacity(0.7))
                    .disabled(email.isEmpty || password.isEmpty || displayName.isEmpty)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    RegisterView()
}

//
//  ProfileView.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var newName = ""
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
            
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                // User info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email: \(auth.currentUser?.email ?? "-")")
                    Text("Display Name: \(auth.currentUser?.displayName ?? "-")")
                    Text("Active: \(auth.currentUser?.isActive == true ? "Yes" : "No")")
                }
                .foregroundColor(.white.opacity(0.8))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal)
                
                .fontWeight(.heavy)
                
                // Update display name
                VStack(spacing: 12) {
                    TextField("", text: $newName, prompt: Text("New Display Name").foregroundColor(.white.opacity(0.6)))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)

                    Button("Save") {
                        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
                            self.errorMessage = "Display name cannot be empty"
                            return
                        }

                        auth.updateProfile(displayName: newName) { result in
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
                    .disabled(newName.isEmpty)
                }
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Sign out
                Button(role: .destructive) {
                    //Added by Alvaro, once logged out the song stops
                    PlayerStateManager.shared.stop()
                    let result = auth.signOut()
                    if case .failure(let failure) = result {
                        self.errorMessage = failure.localizedDescription
                    } else {
                        self.errorMessage = nil
                    }
                } label: {
                    Text("Sign Out")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.4))
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}


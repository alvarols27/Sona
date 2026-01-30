//
//  AddMoodView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-20.
//
//
//
import SwiftUI

struct AddMoodView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var moodService = MoodService.shared
    
    @State private var moodName = ""
    @State private var selectedEmoji = ""
    @State private var moodDescription = ""
    @State private var selectedColor = Color.pink
    @State private var showingColorPicker = false
    
    // set default colors
    let defaultColors = [
        Color.red, Color.orange, Color.yellow, Color.green,
        Color.blue, Color.purple, Color.pink, Color.indigo
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.11, green: 0.00, blue: 0.15),
                        Color(red: 0.24, green: 0.00, blue: 0.46)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 15) {
                        // preview
                        VStack(spacing: 8) {
                            Text(selectedEmoji)
                                .font(.system(size: 50))
                            Text(moodName.isEmpty ? "Vibing?" : moodName)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            if !moodDescription.isEmpty {
                                Text(moodDescription)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedColor)
                        )
                        .padding(.horizontal)
                        
                        // mood name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mood Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("", text: $moodName)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // emoji
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Emoji")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("", text: $selectedEmoji)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // color
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Color")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button("Custom Color") {
                                    showingColorPicker.toggle()
                                }
                                .font(.subheadline)
                                .foregroundColor(.pink)
                            }
                            
                            // default colrs
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(defaultColors, id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                        showingColorPicker = false
                                    } label: {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
                            
                            // colorpicker
                            if showingColorPicker {
                                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                                    .labelsHidden()
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .padding(.horizontal, 22)
                            }
                        }
                        .padding(.horizontal)
                        
                        // description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("", text: $moodDescription)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // create button
                        Button {
                            createMood()
                        } label: {
                            Text("Create Mood")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(moodName.isEmpty ? Color.gray : Color.pink)
                                )
                        }
                        .disabled(moodName.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add New Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func createMood() {
        // Convert Color to String for storage
        let colorName = selectedColor.toHex() ?? "pink"
        
        let newMood = Mood(
            id: UUID().uuidString,
            name: moodName,
            emoji: selectedEmoji,
            description: moodDescription.isEmpty ? nil : moodDescription,
            colorName: colorName
        )
        
        moodService.saveMood(newMood) { result in
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                print("Error saving mood: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    AddMoodView()
}

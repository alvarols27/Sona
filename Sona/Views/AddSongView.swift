//
//  AddSongView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-22.
//
import SwiftUI
import UniformTypeIdentifiers

struct AddSongView: View {
    @Environment(\.dismiss) private var dismiss
    let mood: Mood
    
    @State private var songTitle = ""
    @State private var artistName = ""
    @State private var selectedFileURL: URL?
    @State private var coverURL = "" //cover is an url
    @State private var isImporting = false
    @State private var isUploading = false
    @StateObject private var audioTrimmer = AudioTrimmer()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(mood.colorName)
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Song Details")
                        .foregroundColor(.white)) {
                            TextField("Song Title", text: $songTitle)
                                .foregroundColor(.white)
                            TextField("Artist", text: $artistName)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.white.opacity(0.2))
                    
                    Section(header: Text("Album Cover URL")
                        .foregroundColor(.white)) {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Paste image URL here", text: $coverURL)
                                    .foregroundColor(.white)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                
                                // cover preview
                                if !coverURL.isEmpty, let url = URL(string: coverURL) {
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Preview:")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    ProgressView()
                                                        .foregroundColor(.white)
                                                )
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                } else if !coverURL.isEmpty {
                                    Text("Invalid URL")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.2))
                    
                    Section(header: Text("Audio File")
                        .foregroundColor(.white)) {
                            if let fileURL = selectedFileURL {
                                HStack {
                                    Image(systemName: "music.note")
                                        .foregroundColor(.white)
                                    Text(fileURL.lastPathComponent)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    Button("Remove") {
                                        selectedFileURL = nil
                                    }
                                    .foregroundColor(.red)
                                }
                            } else {
                                Button {
                                    isImporting = true
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.white)
                                        Text("Select Audio File (MP3 or WAV only)")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.2))
                    
                    Section {
                        Button {
                            addSong()
                        } label: {
                            if isUploading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Add Song Preview")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(songTitle.isEmpty || artistName.isEmpty || selectedFileURL == nil || isUploading)
                    }
                    .listRowBackground(Color.white.opacity(0.2))
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Add to \(mood.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.mp3, UTType.audio],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFileURL = url
                    }
                case .failure(let error):
                    print("File import error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func addSong() {
        guard let fileURL = selectedFileURL else { return }
        isUploading = true
        
        print("Processing audio file: \(fileURL.lastPathComponent)")
        
        // Validate URL if provided
        let finalCoverURL = coverURL.isEmpty ? nil : coverURL
        if let urlString = finalCoverURL, URL(string: urlString) == nil {
            print("Invalid cover URL provided")
            isUploading = false
            return
        }
        
        audioTrimmer.trimAudioToSeconds(sourceURL: fileURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioData):
                    // convert to Base64 for Firestore storage
                    let base64String = audioData.base64EncodedString()
                    print("Audio processed: \(audioData.count) bytes → Base64: \(base64String.count) chars")
                    
                    let newSong = Song(
                        id: UUID().uuidString,
                        title: songTitle,
                        artist: artistName,
                        moodID: mood.id ?? "",
                        audioData: base64String,
                        coverURL: finalCoverURL //store cover as url in Firestore
                    )
                    
                    SongService.shared.saveSong(newSong) { result in
                        isUploading = false
                        switch result {
                        case .success:
                            print("Song preview saved to Firestore")
                            dismiss()
                        case .failure(let error):
                            print("Error saving song: \(error.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    isUploading = false
                    print("Error processing audio: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    AddSongView(mood: Mood(
        id: "2",
        name: "Sleep",
        emoji: "🌙",
        description: "Relax vibes",
        colorName: "#2c0080"
    ))
}

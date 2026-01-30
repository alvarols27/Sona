//
//  SearchView.swift
//  Sona
//

import SwiftUI
import UIKit
import FirebaseFirestore

struct SearchView: View {
    // MARK: - Services
    @StateObject private var moodService = MoodService.shared
    @StateObject private var songService = SongService.shared
    
    // MARK: - State
    @State private var searchText: String = ""
    @State private var searchMode: SearchMode = .songs
    @State private var filteredSongs: [Song] = []
    @State private var filteredMoods: [Mood] = []
    
    // MARK: - Segmented Control Styling
    init() {
        let appearance = UISegmentedControl.appearance()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        appearance.selectedSegmentTintColor = UIColor.systemPurple
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            // Search mode picker
            Picker("Search Type", selection: $searchMode) {
                ForEach(SearchMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Search bar
            SearchBar(
                searchText: $searchText,
                placeholder: "Search \(searchMode.rawValue)...",
                onChange: performSearch
            )
            .padding(.horizontal)
            
            // Results
            if !searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        if searchMode == .songs {
                            SongResultsList(
                                songs: filteredSongs,
                                moodFor: moodFor
                            )
                        } else {
                            MoodResultsList(
                                moods: filteredMoods,
                                songsForMood: songsForMood
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 160)
            }
        }
        .onAppear {
            moodService.listenToUserMoods()
            
            songService.listenToUserSongs { result in
                switch result {
                case .success(let songs):
                    print("Songs loaded in SearchView: \(songs.count)")
                    print("Song titles: \(songs.map { $0.title })")
                case .failure(let error):
                    print("Error loading songs: \(error)")
                }
            }
        }
        .onDisappear {
            moodService.stopListening()
            songService.stopListening()
        }
    }
    
    
    // MARK: - Search Logic
    private func performSearch() {
        guard !searchText.isEmpty else {
            filteredSongs.removeAll()
            filteredMoods.removeAll()
            return
        }
        
        let searchLowercased = searchText.lowercased()
        
        switch searchMode {
        case .songs:
            filteredSongs = songService.allSongs.filter { song in
                let titleMatch = song.title.lowercased().contains(searchLowercased)
                let artistMatch = song.artist.lowercased().contains(searchLowercased)
                return titleMatch || artistMatch
            }
            .sorted { $0.title < $1.title } // Optional: sort results
        case .moods:
            filteredMoods = moodService.userMoods.filter { mood in
                mood.name.lowercased().contains(searchLowercased)
            }
            .sorted { $0.name < $1.name } // Optional: sort results
        }
    }
    
    private func moodFor(_ song: Song) -> Mood {
        moodService.userMoods.first(where: { $0.id == song.moodID }) ??
        moodService.userMoods.first ??
        Mood(id: "default", name: "Unknown", emoji: "❓", colorName: "gray")
    }
    
    private func songsForMood(_ mood: Mood) -> [Song] {
        songService.allSongs.filter { $0.moodID == mood.id }
    }
}


// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var searchText: String
    let placeholder: String
    let onChange: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            TextField(placeholder, text: $searchText)
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: searchText) { _ in onChange() }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.purple.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}


// MARK: - Song Results Component
struct SongResultsList: View {
    let songs: [Song]
    let moodFor: (Song) -> Mood
    
    var body: some View {
        ForEach(songs.prefix(2), id: \.id) { song in
            Button {
                let mood = moodFor(song)
                PlayerStateManager.shared.playSong(song, mood: mood, songList: songs)
                PlayerStateManager.shared.showNowPlayingView()
            } label: {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.25))
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Mood Results Component
struct MoodResultsList: View {
    let moods: [Mood]
    let songsForMood: (Mood) -> [Song]
    
    var body: some View {
        ForEach(moods.prefix(2), id: \.id) { mood in
            NavigationLink(
                destination: SongPlaylistByMoodView(mood: mood)
            ) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mood.name)
                            .font(.headline)
                            .foregroundColor(Color(mood.colorName))
                        
                        Text("\(songsForMood(mood).count) songs")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    
                    Text(mood.emoji)
                        .font(.title2)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.25))
                )
            }
        }
    }
}

enum SearchMode: String, CaseIterable {
    case songs
    case moods
}


// Preview
#Preview {
    NavigationStack {
        SearchView()
            .background(Color.purple.opacity(0.2))
    }
}

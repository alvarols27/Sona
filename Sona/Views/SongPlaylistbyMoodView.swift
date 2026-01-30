//
//  SongPlaylistByMoodView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//
// Shows now songs for a mood, fetched from Firestore only for the current user. (2025-11-15)
// Implemented favourites (Tab buttons) and add songs. (2025-11-23)
//
import FirebaseAuth
import SwiftUI

struct SongPlaylistByMoodView: View {
    let mood: Mood
    @ObservedObject private var songService = SongService.shared
    @State private var showingAddSong = false
    @State private var songToDelete: Song?
    @State private var showingDeleteAlert = false
    @State private var selectedTab = 0
    @EnvironmentObject private var playerState: PlayerStateManager
    
    private var songs: [Song] {
        songService.songsByMood
    }
    
    private var favouriteSongs: [Song] {
        songs.filter { $0.isFavourite }
    }
    
    private var displayedSongs: [Song] {
        selectedTab == 0 ? songs : favouriteSongs
    }
    
    var body: some View {
        ZStack {
            Color(mood.colorName)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("\(mood.name) Playlist")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding([.top, .horizontal])
                
                HStack {
                    TabButton(title: "All Songs", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "Favourites", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(displayedSongs, id: \.id) { song in
                            SongRowView(
                                song: song,
                                mood: mood,
                                songs: displayedSongs,
                                onToggleFavourite: {
                                    toggleFavourite(song: song)
                                },
                                onDelete: {
                                    songToDelete = song
                                    showingDeleteAlert = true
                                }
                            )
                            .environmentObject(playerState)
                        }
                        
                        if selectedTab == 0 {
                            Button {
                                showingAddSong = true
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.7))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Add a new song!")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Tap to add music")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.2))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSong) {
            AddSongView(mood: mood)
        }
        .alert("Delete Song", isPresented: $showingDeleteAlert, presenting: songToDelete) { song in
            Button("Cancel", role: .cancel) {
                songToDelete = nil
            }
            Button("Delete", role: .destructive) {
                deleteSong(song)
            }
        } message: { song in
            Text("Are you sure you want to delete \"\(song.title)\"?")
        }
        .onAppear {
            startListeningToSongs()
        }
        .onDisappear {
            songService.stopListening()
        }
    }
    
    private func startListeningToSongs() {
        guard let moodID = mood.id else { return }
        
        songService.listenToSongsByMood(moodID) { result in
            switch result {
            case .success(let fetchedSongs):
                print("Live update received: \(fetchedSongs.count) songs")
                for song in fetchedSongs {
                    print("\(song.title) - Favourite: \(song.isFavourite)")
                }
            case .failure(let error):
                print("Listener error: \(error.localizedDescription)")
                self.fetchSongsForMood()
            }
        }
    }
    
    private func fetchSongsForMood() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let moodID = mood.id else {
            return
        }
        
        print("Fetching songs for mood: \(moodID)")
        
        songService.fetchSongsByMood(moodID, userID: uid) { result in
            switch result {
            case .success(let fetchedSongs):
                print("Fetched \(fetchedSongs.count) songs")
            case .failure(let error):
                print("Error fetching songs: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleFavourite(song: Song) {
        guard let songId = song.id else { return }
                
        SongService.shared.toggleFavourite(songId: songId) { result in
            switch result {
            case .success:
                print("Favourite toggled for song: \(song.title)")
            case .failure(let error):
                print("Error toggling favourite: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteSong(_ song: Song) {
        guard let songId = song.id else { return }
                
        SongService.shared.deleteSong(songId) { result in
            switch result {
            case .success:
                print("Song deleted successfully")
                songToDelete = nil
            case .failure(let error):
                print("Error deleting song: \(error.localizedDescription)")
                songToDelete = nil
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white.opacity(0.3) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SongRowView: View {
    let song: Song
    let mood: Mood
    let songs: [Song]
    let onToggleFavourite: () -> Void
    let onDelete: () -> Void
    
    @EnvironmentObject private var playerState: PlayerStateManager
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if let coverURLString = song.coverURL,
                   let url = URL(string: coverURLString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
            }
            .frame(width: 50, height: 50)
            
            Button {
                playerState.playSong(song, mood: mood, songList: songs)
                playerState.showNowPlayingView()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 8)
            
            Button(action: onToggleFavourite) {
                Image(systemName: song.isFavourite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(song.isFavourite ? .red : .white.opacity(0.6))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.25))
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Song", systemImage: "trash")
            }
        }
    }
}

#Preview {
    SongPlaylistByMoodView(mood: Mood(id: "1", name: "Happy", emoji: "😄", description: "", colorName: "happyColor"))
        .environmentObject(PlayerStateManager.shared)
}

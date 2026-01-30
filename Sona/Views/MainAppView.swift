//
//  MainAppView.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import SwiftUI

struct MainAppView: View {
    @StateObject private var playerState = PlayerStateManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                MoodSelectionView()
                    .tabItem {
                        Label("Sona", systemImage: "waveform")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }
            .tint(.pink)
            .environmentObject(playerState)
            
            // only show when NOT in NowPlayingView
            if let song = playerState.currentSong {
                MiniPlayerBar(
                    song: song,
                    isPlaying: playerState.isPlaying,
                    onPlayPause: {
                        if playerState.isPlaying {
                            playerState.pause()
                        } else {
                            playerState.play()
                        }
                    },
                    onExpand: {
                        playerState.showNowPlayingView()
                    }
                )
                .padding(.bottom, 60) // Add padding to avoid tab bar overlap
                .transition(.move(edge: .bottom))
            }
        }
        //controlled by PlayerStateManager
        .sheet(isPresented: $playerState.isNowPlayingViewActive) {
            if let song = playerState.currentSong,
               let mood = playerState.currentMood {
                NowPlayingView(
                    mood: mood,
                    startSong: song,
                    songs: playerState.currentSongList.isEmpty ? [song] : playerState.currentSongList
                )
                .environmentObject(playerState)
            }
        }
    }
}

#Preview {
    MainAppView()
}

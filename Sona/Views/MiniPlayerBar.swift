//
//  MiniPlayerBar.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-14.
//
// Bottom bar finished to display current playing track (not properly implemented yet). (2025-11-15)

import SwiftUI

struct MiniPlayerBar: View {
    let song: Song
    let isPlaying: Bool
    let onPlayPause: () -> Void
    let onExpand: () -> Void
    
    var body: some View {
        Button(action: onExpand) {
            HStack(spacing: 12) {
                
                songArt
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    onPlayPause()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .shadow(radius: 4)
    }
    
    private var songArt: some View {
        ZStack {
            if let coverURLString = song.coverURL,
               let url = URL(string: coverURLString) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.white.opacity(0.1)
                        .overlay(
                            ProgressView()
                                .foregroundColor(.white)
                        )
                }
                
            } else {
                Color.white.opacity(0.1)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
        }
        .frame(width: 45, height: 45)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    MiniPlayerBar(
        song: Song(
            id: "7",
            title: "Puzzlebox",
            artist: "Aaron",
            moodID: "4",
            audioData: "Puzzlebox",
            coverURL: "https://i.scdn.co/image/ab67616d0000b2732ed5db5c6b5a91746cc79e39"
        ),
        isPlaying: true,
        onPlayPause: {},
        onExpand: {}
    )
}

# Sona
A SwiftUI-based iOS music streaming application that organizes your music library by moods, built with Firebase backend integration. 

Sona is a personalized music player that lets users create custom mood-based playlists with their own music. Upload songs, categorize them by mood, and enjoy a listening experience with features like favourites, shuffle, and song previews.

This is a student project. Contributions, issues, and feature requests are welcome!

# Key Features
# 🎭 Mood Management

- Create Custom Moods: Design personalized mood categories with custom names, emojis, colors, and descriptions
- Color Customization: Choose from preset colors or use a custom color picker
- Real-time Updates: Moods sync instantly across the app using Firestore listeners

# 🎶 Music Library

- Audio Upload: Import MP3 and WAV files from your device
- Song Previews: Automatic audio trimming to ~5 second previews (max 780KB)
- Album Art: Support for custom cover art via URL
- Favorites System: Mark songs as favorites for quick access
- Search Functionality: Search both songs and moods with real-time filtering

# 🎧 Advanced Audio Player

- Persistent Playback: Audio continues playing while navigating between views
- Mini Player Bar: Always-accessible player control at the bottom of the screen
- Full Player View: Expandable now-playing interface with album art
- Playback Controls: Play, pause, next, previous, and shuffle
- Progress Tracking: Real-time progress bar with time indicators
- Auto-advance: Automatically plays the next song when current track finishes

# 👤 User Authentication

- Firebase Authentication: Secure email/password authentication
- User Profiles: Customizable display names
- Session Management: Persistent login with automatic session handling

# 🔍 Search & Discovery

- Dual Search Modes: Toggle between searching songs and moods
- Real-time Results: Instant search results as you type
- Quick Access: Direct playback from search results

# 🛠 Technical Stack
## Frontend

- SwiftUI: Modern declarative UI framework
- Combine: Reactive programming for state management
- AVFoundation: Audio playback engine

## Backend

- Firebase Authentication: User management and security
- Cloud Firestore: Real-time NoSQL database
- Base64 Encoding: Efficient audio data storage in Firestore

## Architecture

- MVVM Pattern: Clear separation of concerns
- Service Layer: Centralized business logic (AuthService, MoodService, SongService)
- Singleton Managers: Shared state management (PlayerStateManager)
- Real-time Listeners: Live data synchronization across views

# 🔥 Firestore Structure
```
users
 └── {uid}
      ├── moods
      │    └── {moodId}
      └── songs
           └── {songId}
```

# 📱 Key Components
## Views

`MoodSelectionView`:  Grid display of user moods<br>
`SongPlaylistByMoodView`: Song list filtered by mood with favorites tab<br>
`NowPlayingView`: Full-screen player with controls and animations<br>
`MiniPlayerBar`: Persistent mini player overlay<br>
`SearchView`: Unified search interface<br>
`AddMoodView`: Mood creation with live preview<br>
`AddSongView`: Song upload with cover art preview<br>
`ProfileView`: User settings and account management

## Services

`AuthService`: Handles user authentication and profile management<br>
`MoodService`: CRUD operations for moods with real-time listeners<br>
`SongService`: Song management, favorites, and Firestore integration<br>
`PlayerStateManager`: Centralized audio playback state<br>
`AudioTrimmer`: Audio processing and optimization

## Models

`AppUser`: User profile data structure<br>
`Mood`: Mood entity with color and emoji support<br>
`Song`: Song metadata with Base64 audio data<br>

# 🎨 Design Highlights

- Custom Gradient Background: Purple-themed dark gradient throughout
- Smooth Animations: Spring-based transitions for song changes
- Responsive UI: Adaptive layouts for different screen sizes
- Context Menus: Long-press actions for delete operations
- Tab System: Organized "All Songs" and "Favorites" views

# 🔐 Security Features

- Email validation with regex pattern matching
- Minimum password length enforcement (6 characters)
- User-specific data isolation in Firestore
- Secure session management

# 📦 Data Management

- User Collections: Each user has isolated mood and song collections
- Real-time Sync: Firestore listeners keep UI updated automatically
- Optimized Storage: Audio previews limited to 780KB to manage Firestore limits
- Cascade Deletion: Deleting a mood removes associated songs

# 🚀 Getting Started

- Clone the repository
- Add your GoogleService-Info.plist file
- Install dependencies via Swift Package Manager
- Build and run on iOS device or simulator

# 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Firebase project with Authentication and Firestore enabled

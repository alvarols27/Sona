//
//  SongService.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-13.
//
// Fetches songs by mood from Firestore, and creates it own collection per user. (2025-11-15)

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class SongService: ObservableObject {
    static let shared = SongService()
    
    @Published var allSongs: [Song] = []
    @Published var songsByMood: [Song] = []
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    
    init() {}
    
    func fetchSongsByMood(_ moodID: String, userID: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        
        db.collection("users")
            .document(userID)
            .collection("songs")
            .whereField("moodID", isEqualTo: moodID)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let list = snapshot?.documents.compactMap {
                    try? $0.data(as: Song.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self.songsByMood = list
                }
                
                completion(.success(list))
            }
    }
    
    
    func listenToUserSongs(completion: ((Result<[Song], Error>) -> Void)? = nil) {
        listener?.remove()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(.failure(SimpleError("No user logged in.")))
            return
        }
        
        listener = db.collection("users")
            .document(uid)
            .collection("songs")
            .order(by: "title")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion?(.success([]))
                    return
                }
                
                let items: [Song] = documents.compactMap { document in
                    do {
                        let song = try document.data(as: Song.self)
                        return song
                    } catch {
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self.allSongs = items
                    completion?(.success(items))
                }
            }
    }
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func listenToSongsByMood(_ moodID: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("No user logged in.")))
            return
        }
        listener?.remove()
        
        listener = db.collection("users")
            .document(uid)
            .collection("songs")
            .whereField("moodID", isEqualTo: moodID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let items: [Song] = snapshot?.documents.compactMap {
                    try? $0.data(as: Song.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self.songsByMood = items
                }
                completion(.success(items))
            }
    }
    
    func saveSong(_ song: Song, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.failure(SimpleError("No user logged in")))
        }
        
        let id = song.id ?? UUID().uuidString
        var songWithId = song
        songWithId.id = id
        
        do {
            try db.collection("users").document(uid)
                .collection("songs")
                .document(id)
                .setData(from: songWithId) { error in
                    
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteSong(_ songId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("No user logged in.")))
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("songs")
            .document(songId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    func toggleFavourite(songId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("No user logged in.")))
            return
        }
        
        let ref = db.collection("users")
            .document(uid)
            .collection("songs")
            .document(songId)
        
        ref.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  var song = try? snapshot.data(as: Song.self) else {
                completion(.failure(SimpleError("Song not found")))
                return
            }
            
            song.isFavourite.toggle()
            
            do {
                try ref.setData(from: song) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.updateLocalSong(song)
                        completion(.success(()))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func updateLocalSong(_ updatedSong: Song) {
        //update sonfgs array
        if let index = allSongs.firstIndex(where: { $0.id == updatedSong.id }) {
            allSongs[index] = updatedSong
        }
        //update moods array
        if let index = songsByMood.firstIndex(where: { $0.id == updatedSong.id }) {
            songsByMood[index] = updatedSong
        }
        
        print("🔄 Locally updated song: \(updatedSong.title) - Favourite: \(updatedSong.isFavourite)")
    }
}

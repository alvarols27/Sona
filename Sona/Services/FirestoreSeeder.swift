//
//  FirestoreSeeder.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-15.
//
// Fixed ID so songs can now match the correct album; we get moods from the Firestore, as well as albums, and songs per new user. (2025-11-15)
// Album model deleted (2025-11-23)
// MARK: PASSWORD IS 123456 FOR EVERY USER TESTED

import FirebaseFirestore
import Foundation
import FirebaseAuth

struct FirestoreSeeder {
    static func seedUserData(for uid: String) {
        let db = Firestore.firestore()
        
        // Moods
        let moods: [Mood] = [
            
        ]
        
        for mood in moods {
            do {
                try db.collection("users").document(uid)
                    .collection("moods").document(mood.id!)
                    .setData(from: mood)
            } catch {
                print("Error seeding mood:", error)
            }
        }
        
        // Songs
        let songs: [Song] = [

        ]
        
        for song in songs {
            do {
                try db.collection("users").document(uid)
                    .collection("songs").document(song.id!)
                    .setData(from: song)
            } catch {
                print("Error seeding song:", error)
            }
        }
    }
}

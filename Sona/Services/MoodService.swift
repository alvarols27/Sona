//
//  MoodService.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-13.
//
// Fetches and saves all moods and also listens to only logged user's ones. (2025-11-15)
// Added mood deletion(2025-11-20)

import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

class MoodService: ObservableObject {
    static let shared = MoodService()
    @Published var userMoods: [Mood] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
        
    func listenToUserMoods() {
        listener?.remove()

        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("users").document(uid)
            .collection("moods")
            .order(by: "name")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Live listener error:", error.localizedDescription)
                    return
                }

                let items: [Mood] = snapshot?.documents.compactMap {
                    try? $0.data(as: Mood.self)
                } ?? []

                DispatchQueue.main.async { //Updates the UI
                    self.userMoods = items
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func saveMood(_ mood: Mood, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("No user logged in.")))
            return
        }

        // Generate ID if nil
        let moodID = mood.id ?? UUID().uuidString
        var moodWithId = mood
        moodWithId.id = moodID

        do {
            try db.collection("users")
                .document(uid)
                .collection("moods")
                .document(moodID)
                .setData(from: moodWithId) { error in

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
    
    //Added by Alvaro
    func deleteMood(_ moodId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(SimpleError("No user logged in.")))
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("moods")
            .document(moodId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}

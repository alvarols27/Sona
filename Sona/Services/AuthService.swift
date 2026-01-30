//
//  File.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthService: ObservableObject{
    
    static let shared = AuthService()
    @Published var currentUser: AppUser?
    private let db = Firestore.firestore()
    
    // SignUp
    func signUp(email: String, password: String, displayName: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            }

            // guard statement
            guard let user = result?.user else {
                return completion(.failure(SimpleError("Unable to create the user")))
            }
            
            // uid from the firebase
            let uid = user.uid
            let appUser = AppUser(id: uid, email: email, displayName: displayName)
            
            do{
                try self.db.collection("users").document(uid).setData(from: appUser){
                    erroe in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                    
                    FirestoreSeeder.seedUserData(for: uid) //Added by Alvaro

                    DispatchQueue.main.async {
                        self.currentUser = appUser
                    }
                    completion(.success(appUser))
                }
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    // login
    func login(email: String, password: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else if let user = result?.user {
                // uid
                _ = user.uid

                // fetch appuser from firestore
                self.fetchCurrentAppUser { res in
                    switch res {
                    case .success(let appUserObj):
                        if let appUser = appUserObj {
                            completion(.success(appUser))
                        } else {
                            completion(.failure(SimpleError("Unable to fecth User Details")))
                        }
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            }
        }
    }
    
    //fecth current user
    func fetchCurrentAppUser(completion: @escaping (Result<AppUser?, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return completion(.success(nil))
        }

        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let snap = snap else {
                return completion(.success(nil))
            }

            do {
                // destructure data stream
                let user = try snap.data(as: AppUser.self)
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                completion(.success(user))
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    // update profile details
    func updateProfile(displayName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // uid
        guard let uid = Auth.auth().currentUser?.uid else {
            return completion(.failure(SimpleError("Unable to fetch User details")))
        }

        db.collection("users").document(uid).updateData(["displayName": displayName]) { error in
            if let error = error {
                return completion(.failure(error))
            } else {
                // re-fetch 
                self.fetchCurrentAppUser { _ in
                    completion(.success(()))
                }
            }
        }
    }
    
    
    //signout
    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            return .success(())
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
}

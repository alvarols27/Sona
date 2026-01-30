//
//  AppUser.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
// // MARK: PASSWORD IS 123456 FOR EVERY USER TESTED

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    var displayName: String
    var isActive: Bool = true
}

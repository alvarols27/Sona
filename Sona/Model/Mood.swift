//
//  Mood.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import Foundation
import FirebaseFirestore

struct Mood: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var emoji: String
    var description: String?
    var colorName: String
}

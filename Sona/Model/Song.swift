//
//  Song.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-03.
//

import Foundation
import FirebaseFirestore

struct Song: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var artist: String
    var moodID: String
    let audioData: String? //It's gonna be now Base64 encoded audio
    var coverURL: String? //Added cover here instead
    var duration: Double = 0.5 //5 seconds preview
    var isFavourite: Bool = false //add to favourites
}

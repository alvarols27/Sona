//
//  AudioTrimmer.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-23.
//

import Foundation
import AVFoundation

class AudioTrimmer: ObservableObject {
    func trimAudioToSeconds(sourceURL: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let audioData = try Data(contentsOf: sourceURL)
            let maxSize = min(audioData.count, 780_000)
            let trimmedData = audioData.prefix(maxSize)
            print("Using fallback trim: \(trimmedData.count) bytes")
            completion(.success(Data(trimmedData)))
            
        } catch {
            print("Fallback also failed: \(error)")
            completion(.failure(error))
        }
    }
}

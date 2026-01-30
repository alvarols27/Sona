//
//  AudioDelegate.swift
//  Sona
//
//  Created by user285578 on 11/16/25.
//

import Foundation
import AVFoundation

class AudioDelegate: NSObject, AVAudioPlayerDelegate {
    /// Callback for when the current track finishes playing.
    var onFinish: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else {
            print("⚠️ Track finished with an error or interruption.")
            return
        }
        onFinish?()
    }
}

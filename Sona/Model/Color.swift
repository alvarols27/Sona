//
//  Color.swift
//  Sona
//
//  Created by Alvaro Limaymanta Soria on 2025-11-21.
//
// Color extension created to handle color picked by users
//
import Foundation
import SwiftUI

extension Color {
    init(_ hexString: String) {
        if hexString.hasPrefix("#"), let color = Color(hex: hexString) {
            self = color
        } else {
            switch hexString {
            case "red": self = .red
            case "orange": self = .orange
            case "yellow": self = .yellow
            case "green": self = .green
            case "blue": self = .blue
            case "purple": self = .purple
            case "pink": self = .pink
            case "indigo": self = .indigo
            default: self = .pink
            }
        }
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let hexString = String(format: "#%02lX%02lX%02lX",
                              lroundf(r * 255),
                              lroundf(g * 255),
                              lroundf(b * 255))
        return hexString
    }
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

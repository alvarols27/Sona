//
//  File.swift
//  Sona
//
//  Created by user278698 on 11/2/25.
//

import Foundation

enum Validators {
    static func isEmailValid(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}

// SimpleError
struct SimpleError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var localizedDescription: String {
        return message
    } // computed property.
}

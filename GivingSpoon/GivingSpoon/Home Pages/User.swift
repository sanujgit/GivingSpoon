//
//  User.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import Foundation

struct User: Identifiable {
    var id: String
    var name: String
    var address: String
    var email: String
    var password: String?
    var userType: String
}

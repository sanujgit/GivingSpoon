//
//  SignUpViewModel.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftUI

class SignupViewModel: NSObject, ObservableObject {
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var userType: String = ""
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var users: [User] = []

    func changeName(new_Name: String) {
        self.name = new_Name
    }

    func changeUserType(type: String) {
        self.userType = type
    }

    func changeEmail(user_email: String) {
        self.email = user_email
    }

    func changeAddress(new_Address: String) {
        self.address = new_Address
    }

    func changePassword(pass: String) {
        self.password = pass
    }
    
    func userSave(uid userUid: String) {
        // Make sure address is at least an empty string
        let safeAddress = address.isEmpty ? "" : address
        
        let data: [String: Any] = [
            "name": name,
            "email": email,
            "role": userType,
            "address": safeAddress
        ]
        
        print("DEBUG: userSave called with UID:", userUid)
        print("DEBUG: userSave data:", data) // <-- this confirms what you are writing
        
        Firestore.firestore().collection("Users").document(userUid).setData(data) { error in
            if let error = error {
                print("DEBUG: Firestore error:", error.localizedDescription)
            } else {
                print("DEBUG: User successfully saved!")
            }
        }
    }

    
//    func userSave(uid userUid: String) {
//        let data: [String: Any] = [
//            "name": name,
//            "email": email,
//            "address": address,
//            "role": userType
//        ]
//
//        print("DEBUG: userSave called with UID:", userUid)
//
//        Firestore.firestore().collection("Users").document(userUid).setData(data) { error in
//            if let error = error {
//                print("DEBUG: Firestore error:", error.localizedDescription)
//            } else {
//                print("User successfully saved!")
//            }
//        }
//    }


//    func userSave(uid userUid: String) {
////        guard let userUid = Auth.auth().currentUser?.uid else {
////            print("No current user UID found!")
////            return
////        }
//
//        let data: [String: Any] = [
//            "name": name,
//            "email": email,
//            "address": address,
//            "role": userType
//        ]
//        
//        print("DEBUG: userSave called with UID:", userUid)
//
//        Firestore.firestore().collection("Users").document(userUid).setData(data) { error in
//            if let error = error {
//                print("DEBUG: Firestore error:", error)
//            } else {
//                print("User successfully saved!")
//            }
//        }
//    }

    func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("Users").getDocuments { (snap, err) in
            guard let documents = snap?.documents else { return }
            self.users = documents.compactMap { doc -> User? in
                let id = doc.documentID
                let name = doc.get("name") as? String ?? ""
                let email = doc.get("email") as? String ?? ""
                let userType = doc.get("role") as? String ?? ""
                let address = doc.get("address") as? String ?? ""
                return User(id: id, name: name, address: address, email: email, password: "", userType: userType)
            }
        }
    }

    func updateProfile(name: String, email: String, role: String, address: String) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            print("No current user UID found!")
            return
        }

        let db = Firestore.firestore()
        db.collection("Users").document(userUid).updateData([
            "name": name,
            "email": email,
            "role": role,
            "address": address
        ]) { err in
            if let err = err {
                print("Error updating profile: \(err.localizedDescription)")
            } else {
                print("User profile successfully updated!")
            }
        }
    }
}


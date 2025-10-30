//
//  DataManager.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore

class DataManager: ObservableObject {
    @Published var users: [User] = []
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers(completion: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        db.collection("Users").getDocuments { (snap, err) in
            guard let itemData = snap else {
                completion?()
                return
            }

            self.users.removeAll()
            self.users = itemData.documents.compactMap { doc in
                let id = doc.documentID
                guard let name = doc.get("name") as? String,
                      let type = doc.get("role") as? String,
                      let email = doc.get("email") as? String,
                      let address = doc.get("address") as? String else {
                    print("Skipping document with missing fields: \(doc.documentID)")
                    return nil
                }
                
                return User(id: id, name: name, address: address, email: email, password: "", userType: type)
            }
            completion?()
        }
    }

    
    func printUsers()
    {
        for user in users
        {
            print(user.name)
        }
        print("DONE")
    }
}


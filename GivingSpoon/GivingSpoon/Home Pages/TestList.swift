//
//  TestList.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct TestList: View {
    @StateObject var dataManager: DataManager = DataManager()
    
    var body: some View {
        NavigationView {
            List(dataManager.users, id: \.id) { user in
                Text(user.name)
            }
            .navigationTitle("Users")
            .navigationBarItems(trailing: Button(action: {
                
            }, label: {
                Image(systemName: "plus")
            }))
        }
    }
}

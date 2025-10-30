//
//  VolunteerSettings.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct VolunteerSettings: View {
    @StateObject var dataManager: DataManager = DataManager()
    @StateObject var viewModel = SignupViewModel()
    
    @Binding var userEmail: String
    @Binding var switchScreen: Bool
    
    enum ActiveAlert: Identifiable {
        case success, logout, delete
        var id: Int { hashValue }
    }
    
    @State private var activeAlert: ActiveAlert?
    @State private var isLogoutRequested = false
    
    init(userEmail: Binding<String>, switchScreen: Binding<Bool>) {
        self._userEmail = userEmail
        self._switchScreen = switchScreen
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF6EE").ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                }
                
//                Image("MealWizardLogoTransparent")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 120, height: 120)
//                    .padding(.top, 30)
                
                Text("My Profile")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))
                
                VStack(spacing: 15) {
                    // Role display
                    Text("You are set up as a \(viewModel.userType.capitalized)")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "#E14C22"))
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    // Instruction
                    Text("Change your account information by editing below and then clicking 'Update'")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    // Name label + field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Name:")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.black)
                        CustomTextField(placeholder: "Name", text: $viewModel.name)
                    }

                    // Email label + field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email:")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.black)
                        CustomTextField(placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 15) {
                    CapsuleButton(title: "Update", bgColor: "#F35B04") {
                        viewModel.updateProfile(
                            name: viewModel.name,
                            email: viewModel.email,
                            role: viewModel.userType,
                            address: viewModel.address
                        )
                        activeAlert = .success
                    }
                    
                    CapsuleButton(title: "Logout", bgColor: "#FFFFFF", textColor: Color(hex: "#E14C22")) {
                        isLogoutRequested = true
                        activeAlert = .logout
                    }

                    CapsuleButton(title: "Delete Account", bgColor: "#FF0000") {
                        activeAlert = .delete
                    }
                }
                .padding(.bottom, 30)
            }
            .onAppear {
                if dataManager.users.isEmpty {
                    dataManager.fetchUsers {
                        assignUserData()
                    }
                } else {
                    assignUserData()
                }
            }
            .alert(item: $activeAlert) { alertType in
                switch alertType {
                case .success:
                    return Alert(
                        title: Text("Profile Updated"),
                        message: Text("Your settings have been successfully updated."),
                        dismissButton: .default(Text("Done"))
                    )
                case .logout:
                    return Alert(
                        title: Text("Are you sure?"),
                        message: Text("You will be logged out of your account."),
                        primaryButton: .destructive(Text("Yes")) {
                            if isLogoutRequested {
                                logout()
                                switchScreen = true
                            }
                        },
                        secondaryButton: .cancel()
                    )
                case .delete:
                    return Alert(
                        title: Text("Are you sure?"),
                        message: Text("Deleting your account will permanently remove all your data."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    func assignUserData() {
        if let user = dataManager.users.first(where: { $0.email == userEmail }) {
            viewModel.changeName(new_Name: user.name)
            viewModel.changeUserType(type: user.userType)
            viewModel.changeEmail(user_email: user.email)
            viewModel.changeAddress(new_Address: user.address)
        }
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        let firebaseAuth = Auth.auth()
        let db = Firestore.firestore()

        let usersRef = db.collection("Users")
        usersRef.whereField("email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error finding user document: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No matching user document found")
                return
            }

            let dispatchGroup = DispatchGroup()

            for document in documents {
                dispatchGroup.enter()
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting user document: \(error.localizedDescription)")
                    } else {
                        print("User document deleted from Firestore.")
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                firebaseAuth.currentUser?.delete { error in
                    if let error = error {
                        print("Error deleting account from Firebase Auth: \(error.localizedDescription)")
                    } else {
                        print("User account deleted from Firebase Auth.")
                        logout()
                        switchScreen = true
                    }
                }
            }
        }
    }
}

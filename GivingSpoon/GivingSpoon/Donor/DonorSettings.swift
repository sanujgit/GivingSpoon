//
//  DonorSettings.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct DonorSettings: View {
    @StateObject var dataManager: DataManager = DataManager()
    @StateObject var viewModel = SignupViewModel()

    @Binding var userEmail: String
    @Binding var switchScreen: Bool
    @Binding var loggedIn: Bool

    enum ActiveAlert: Identifiable {
        case success, logout, delete
        var id: Int { hashValue }
    }

    @State private var activeAlert: ActiveAlert?

    init(userEmail: Binding<String>, switchScreen: Binding<Bool>, loggedIn: Binding<Bool>) {
        self._userEmail = userEmail
        self._switchScreen = switchScreen
        self._loggedIn = loggedIn
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
                    // Display the user's role
                    Text("You are set up as a \(viewModel.userType.capitalized)")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "#E14C22"))
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    // Instructions
                    Text("Change your account information by editing below and then clicking 'Update'")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    // Name field with label
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Name:")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.black)
                        CustomTextField3(placeholder: "Name", text: $viewModel.name)
                    }

                    // Email field with label
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email:")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.black)
                        CustomTextField3(placeholder: "Email", text: $viewModel.email, keyboardType: .emailAddress)
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

                    WhiteOutlineButton(title: "Logout", borderColor: "#E14C22") {
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
                            logout()
                            switchScreen = true
                        },
                        secondaryButton: .cancel()
                    )
                case .delete:
                    return Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action is permanent."),
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
        let db = Firestore.firestore()

        db.collection("Users").whereField("email", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, !snapshot.documents.isEmpty else {
                print("No user document found.")
                return
            }

            let dispatchGroup = DispatchGroup()

            for document in snapshot.documents {
                dispatchGroup.enter()
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting Firestore doc: \(error.localizedDescription)")
                    } else {
                        print("Firestore doc deleted.")
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                let user = Auth.auth().currentUser
                user?.delete { error in
                    if let error = error {
                        print("Error deleting Firebase Auth user: \(error.localizedDescription)")
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

struct CustomTextField3: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(placeholder, text: $text)
                .font(.system(size: 18, design: .serif))
                .padding()
                .frame(width: 320, height: 55) // Match the button size
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#E14C22").opacity(0.4), lineWidth: 1)
                )
                .keyboardType(keyboardType)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .padding(.vertical, 4)
    }
}

struct CapsuleButton: View {
    var title: String
    var bgColor: String
    var textColor: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, design: .serif))
                .foregroundColor(textColor)
                .frame(width: 320, height: 55)
                .background(Color(hex: bgColor))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
        }
    }
}



struct WhiteOutlineButton: View {
    var title: String
    var borderColor: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, design: .serif))
                .foregroundColor(Color(hex: borderColor))
                .frame(width: 320, height: 55)
                .background(Color.white)
                .overlay(
                    Capsule()
                        .stroke(Color(hex: borderColor), lineWidth: 2)
                )
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
}

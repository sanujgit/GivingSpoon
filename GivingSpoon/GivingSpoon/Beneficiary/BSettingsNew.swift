//
//  BSettingsNew.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

struct BSettingsNew: View {
    @StateObject var dataManager: DataManager = DataManager()
    @StateObject var viewModel = SignupViewModel()

    @Binding var userEmail: String
    @Binding var switchScreen: Bool
    @State private var activeAlert: ActiveAlert?

    enum ActiveAlert: Identifiable {
        case success, logout, delete
        var id: Int { hashValue }
    }

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

                Text("My Profile")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))

                VStack(spacing: 15) {
                    // Role display
                    Text("You are set up as a Beneficiary")
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
                    CapsuleButton(title: "Update", bgColor: "#E14C22") {
                        viewModel.updateProfile(
                            name: viewModel.name,
                            email: viewModel.email,
                            role: viewModel.userType,
                            address: viewModel.address
                        )
                        activeAlert = .success
                    }

                    CapsuleButton(title: "Logout", bgColor: "#FFFFFF", textColor: Color(hex: "#E14C22")) {
                        activeAlert = .logout
                    }

                    CapsuleButton(title: "Delete Account", bgColor: "#FF0000") {
                        activeAlert = .delete
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
            .onAppear {
                if dataManager.users.isEmpty {
                    dataManager.fetchUsers {
                        assignUserData()
                    }
                } else {
                    assignUserData()
                }
            }
            .alert(item: $activeAlert) { alert in
                switch alert {
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
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let dispatchGroup = DispatchGroup()

        db.collection("Users").whereField("email", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("No matching user document found.")
                return
            }

            for document in snapshot.documents {
                dispatchGroup.enter()
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting Firestore document: \(error.localizedDescription)")
                    } else {
                        print("User Firestore document deleted.")
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                user.delete { error in
                    if let error = error {
                        print("Error deleting Firebase Auth account: \(error.localizedDescription)")
                    } else {
                        print("Firebase Auth account deleted.")
                        logout()
                        switchScreen = true
                    }
                }
            }
        }
    }
}

struct CustomTextField2: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.black.opacity(0.7))

            if isSecure {
                SecureField("Enter \(title)", text: $text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField("Enter \(title)", text: $text)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.vertical, 5)
    }
}

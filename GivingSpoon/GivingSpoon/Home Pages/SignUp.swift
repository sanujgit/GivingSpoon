//
//  SignUp.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .frame(width: 340, height: 55)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .frame(width: 340, height: 55)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SignUp: View {
    @StateObject var viewModel = SignupViewModel()
    @State private var selectedOption: String = "Donor"
    @State private var newEmail: String = ""
    @State private var newAddress: String = ""
    @State private var newPass: String = ""
    @State private var confirmPass: String = ""
    @State private var newName: String = ""
    @Binding var showHome: Bool
    @Binding var email: String
    @Binding var loggedIn: Bool
    @State private var switchToHome: Bool = false
    @State private var goToLogin: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let options = ["Donor", "Beneficiary", "Volunteer"]

    var body: some View {
        signUpView
            .navigate(to: HomeView(), when: $switchToHome)
            .navigate(to: Login(), when: $goToLogin)
    }

    var signUpView: some View {
        ZStack {
            Color(hex: "#FFF6EE").ignoresSafeArea()
            VStack {
                // Back button
                HStack {
                    Button {
                        switchToHome = true
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(Color(hex: "#E14C22"))
                            .font(.system(size: 20))
                            .padding()
                            .background(Color(hex: "#E14C22").opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 10)
                    .padding(.top, 10)
                    Spacer()
                }

                Spacer()
                Image("MealWizardLogoTransparent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.bottom, 10)

                Text("Sign Up")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))
                    .padding(.bottom, 5)

                VStack(spacing: 15) {
                    CustomTextField(placeholder: "Name", text: $newName)
                    CustomTextField(placeholder: "Email", text: $newEmail, keyboardType: .emailAddress)
                    // CustomTextField(placeholder: "Address (optional)", text: $newAddress)
                    CustomSecureField(placeholder: "Password", text: $newPass)
                    CustomSecureField(placeholder: "Confirm Password", text: $confirmPass)

                    Menu {
                        ForEach(options, id: \.self) { option in
                            Button(option) { selectedOption = option }
                        }
                    } label: {
                        HStack {
                            Text(selectedOption).foregroundColor(.black).font(.system(size: 20, design: .serif))
                            Spacer()
                            Image(systemName: "chevron.down").foregroundColor(.gray)
                        }
                        .padding()
                        .frame(width: 340, height: 55)
                        .background(Color.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)

                Spacer()

                Button {
                    signUp()
                } label: {
                    Text("Sign Up")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .frame(width: 320, height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#E14C22").opacity(0.9), Color(hex: "#E14C22")]),
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "#E14C22").opacity(0.3), radius: 6, x: 2, y: 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    func signUp() {
        print("DEBUG: signUp() function called")

        guard newPass.count >= 7 else {
            alertMessage = "Password must be at least 7 characters long."
            showAlert = true
            return
        }

        guard newPass == confirmPass else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }

        guard validateEmailAddress(newEmail) else {
            alertMessage = "Please enter a valid email."
            showAlert = true
            return
        }

        Auth.auth().createUser(withEmail: newEmail, password: newPass) { result, error in
            if let error = error {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
                print("Auth error:", error.localizedDescription)
                return
            }

            guard let createdUser = result?.user else {
                alertMessage = "Account created, but user details missing."
                showAlert = true
                return
            }

            print("DEBUG: Auth user created:", createdUser.uid)

            // Update ViewModel properties BEFORE saving
            viewModel.changeName(new_Name: newName)
            viewModel.changeUserType(type: selectedOption)
            viewModel.changeEmail(user_email: newEmail)
            viewModel.changeAddress(new_Address: newAddress)

            // Save to Firestore
            viewModel.userSave(uid: createdUser.uid)
            print("DEBUG: viewModel.userSave() called.")

            // Optional test write
            Firestore.firestore().collection("DebugTest").addDocument(data: [
                "message": "Hello Firestore!", "timestamp": Timestamp()
            ]) { error in
                if let error = error { print("DEBUG: Direct test write failed:", error) }
                else { print("DEBUG: Direct test write succeeded!") }
            }

            goToLogin = true
            print("DEBUG: Navigating to login")
        }
    }

    func validateEmailAddress(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}

// ViewModel remains the same as your last version; it handles optional empty address


//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//struct CustomTextField: View {
//    var placeholder: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//
//    var body: some View {
//        TextField(placeholder, text: $text)
//            .keyboardType(keyboardType)
//            .autocapitalization(.none)
//            .disableAutocorrection(true)
//            .padding()
//            .frame(width: 340, height: 55)
//            .background(Color.white)
//            .cornerRadius(15)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
//            )
//            .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
//    }
//}
//
//struct CustomSecureField: View {
//    var placeholder: String
//    @Binding var text: String
//
//    var body: some View {
//        SecureField(placeholder, text: $text)
//            .textContentType(.oneTimeCode)
//            .autocapitalization(.none)
//            .disableAutocorrection(true)
//            .padding()
//            .frame(width: 340, height: 55)
//            .background(Color.white)
//            .cornerRadius(15)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
//            )
//            .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
//    }
//}
//
//struct SignUp: View {
//    @StateObject var viewModel = SignupViewModel()
//    @State private var selectedOption: String = "Donor"
//    @State private var isSignedUp: Bool = false
//    @State private var newEmail: String = ""
//    @State private var newAddress: String = ""
//    @State private var newPass: String = ""
//    @State private var confirmPass: String = ""
//    @State private var newName: String = ""
//    @Binding var showHome: Bool
//    @State private var showAlert: Bool = false
//    @State private var alertMessage: String = ""
//    @Binding var email: String
//    @Binding var loggedIn: Bool
//    @State private var switchToHome: Bool = false
//    @State private var goToLogin: Bool = false
//
//    let options = ["Donor", "Beneficiary", "Volunteer"]
//
//    var body: some View {
//        signUpView
//            .navigate(to: HomeView(), when: $switchToHome)
//            .navigate(to: Login(), when: $goToLogin)
//    }
//
//    var signUpView: some View {
//        ZStack {
//            Color(hex: "#FFF6EE")
//                .ignoresSafeArea()
//
//            VStack {
//                HStack {
//                    Button {
//                        switchToHome = true
//                    } label: {
//                        Image(systemName: "arrow.backward")
//                            .foregroundColor(Color(hex: "#E14C22"))
//                            .font(.system(size: 20))
//                            .padding()
//                            .background(Color(hex: "#E14C22").opacity(0.1))
//                            .clipShape(Circle())
//                    }
//                    .padding(.leading, 10)
//                    .padding(.top, 10)
//
//                    Spacer()
//                }
//
//                Spacer()
//
//                Image("MealWizardLogoTransparent")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 120, height: 120)
//                    .padding(.bottom, 10)
//
//                Text("Sign Up")
//                    .font(.system(size: 40, weight: .bold, design: .serif))
//                    .foregroundColor(Color(hex: "#E14C22"))
//                    .padding(.bottom, 5)
//
//                VStack(spacing: 15) {
//                    CustomTextField(placeholder: "Name", text: $newName)
//                    CustomTextField(placeholder: "Email", text: $newEmail, keyboardType: .emailAddress)
//                    CustomSecureField(placeholder: "Password", text: $newPass)
//                    CustomSecureField(placeholder: "Confirm Password", text: $confirmPass)
//
//                    Menu {
//                        ForEach(options, id: \.self) { option in
//                            Button(option) {
//                                selectedOption = option
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            Text(selectedOption)
//                                .foregroundColor(.black)
//                                .font(.system(size: 20, design: .serif))
//                            Spacer()
//                            Image(systemName: "chevron.down")
//                                .foregroundColor(.gray)
//                        }
//                        .padding()
//                        .frame(width: 340, height: 55)
//                        .background(Color.white)
//                        .cornerRadius(15)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
//                        )
//                        .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 30)
//
//                Spacer()
//
//                Button {
//                    signUp()
//                } label: {
//                    Text("Sign Up")
//                        .font(.system(size: 24, weight: .bold, design: .serif))
//                        .foregroundColor(.white)
//                        .frame(width: 320, height: 60)
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color(hex: "#E14C22").opacity(0.9), Color(hex: "#E14C22")]),
//                                startPoint: .leading,
//                                endPoint: .trailing)
//                        )
//                        .clipShape(Capsule())
//                        .shadow(color: Color(hex: "#E14C22").opacity(0.3), radius: 6, x: 2, y: 4)
//                }
//                .padding(.top, 20)
//                .padding(.bottom, 20)
//                .alert(isPresented: $showAlert) {
//                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//                }
//            }
//        }
//    }
//    
//    func signUp() {
//        print("DEBUG: signUp() function called at very top.")
//
//        // Validate password length
//        guard newPass.count >= 7 else {
//            alertMessage = "Password must be at least 7 characters long."
//            showAlert = true
//            print("DEBUG: Password validation failed: too short.")
//            return
//        }
//
//        // Validate password match
//        guard newPass == confirmPass else {
//            alertMessage = "Passwords do not match."
//            showAlert = true
//            print("DEBUG: Password validation failed: mismatch.")
//            return
//        }
//
//        // Validate email format
//        guard validateEmailAddress(newEmail) else {
//            alertMessage = "Please enter a valid email address."
//            showAlert = true
//            print("DEBUG: Email validation failed: invalid format.")
//            return
//        }
//
//        // Create user in Firebase Auth
//        Auth.auth().createUser(withEmail: newEmail, password: newPass) { result, error in
//            if let error = error {
//                print("Auth error: \(error.localizedDescription)")
//                alertMessage = "Error: \(error.localizedDescription)"
//                showAlert = true
//                return
//            }
//
//            guard let createdUser = result?.user else {
//                alertMessage = "Account created, but failed to retrieve user details."
//                showAlert = true
//                print("DEBUG: Firebase createUser succeeded, but result.user was nil.")
//                return
//            }
//
//            print("DEBUG: Auth user created:", createdUser.uid)
//
//            // Update ViewModel properties BEFORE saving to Firestore
//            viewModel.changeName(new_Name: newName)
//            viewModel.changeUserType(type: selectedOption)
//            viewModel.changeEmail(user_email: newEmail)
//            viewModel.changeAddress(new_Address: newAddress)
//
//            // Save to Firestore
//            viewModel.userSave(uid: createdUser.uid)
//
//            // Test write to Firestore
//            Firestore.firestore().collection("DebugTest").addDocument(data: [
//                "message": "Hello Firestore!",
//                "timestamp": Timestamp()
//            ]) { error in
//                if let error = error {
//                    print("DEBUG: Direct test write failed:", error)
//                } else {
//                    print("DEBUG: Direct test write succeeded!")
//                }
//            }
//
//            print("DEBUG: viewModel.userSave() called.")
//            goToLogin = true
//            print("DEBUG: Navigating to login.")
//        }
//    }
//
//
////    func signUp() {
////        print("DEBUG: signUp() function called at very top.")
////        
////        guard newPass.count >= 7 else {
////            alertMessage = "Password must be at least 7 characters long."
////            showAlert = true
////            print("DEBUG: Password validation failed: too short.")
////            return
////        }
////
////        guard newPass == confirmPass else {
////            alertMessage = "Passwords do not match."
////            showAlert = true
////            print("DEBUG: Password validation failed: mismatch.")
////            return
////        }
////
////        guard validateEmailAddress(newEmail) else {
////            alertMessage = "Please enter a valid email address."
////            showAlert = true
////            print("DEBUG: Email validation failed: invalid format.")
////            return
////        }
////
////        Auth.auth().createUser(withEmail: newEmail, password: newPass) { result, error in
////            if let error = error {
////                    print("Auth error: \(error.localizedDescription)")
////                    return
////            }
////            
////            print("DEBUG: Auth user created:", result?.user.uid ?? "no uid")
////
////            let db = Firestore.firestore()
////            db.collection("Users").document(result!.user.uid).setData([
////                "email": newEmail,
////                "createdAt": Timestamp()
////            ]) { error in
////                if let error = error {
////                    print("DEBUG: Firestore write error:", error.localizedDescription)
////                } else {
////                    print("DEBUG: Successfully wrote user to Firestore")
////                }
////            }
////            
////            if let error = error {
////                alertMessage = "Error: \(error.localizedDescription)"
////                showAlert = true
////            } else {
////                print("DEBUG: Firebase createUser succeeded.")
////                // User successfully created in Firebase Auth!
////                // Now, safely get the user object from the result.
////                if let createdUser = result?.user {
////                    // Update viewModel's properties
////                    viewModel.changeName(new_Name: newName)
////                    viewModel.changeUserType(type: selectedOption)
////                    viewModel.changeEmail(user_email: newEmail)
////                    // (You might want to ensure newEmail is used consistently for the ViewModel's email)
////                    
////                    // DEBUGGING START
////                    Firestore.firestore().collection("DebugTest").addDocument(data: [
////                        "message": "Hello Firestore!",
////                        "timestamp": Timestamp()
////                    ]) { error in
////                        if let error = error {
////                            print("DEBUG: Direct test write failed:", error)
////                        } else {
////                            print("DEBUG: Direct test write succeeded!")
////                        }
////                    }
////                    // DEBUGGING END
////
////                    // Call userSave() with the obtained user's UID
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////                        viewModel.userSave(uid: createdUser.uid)
////                    }
////                    print("DEBUG: viewModel.userSave() called.")
////                } else {
////                    alertMessage = "Account created, but failed to retrieve user details to save to database."
////                    showAlert = true
////                    print("DEBUG: Firebase createUser succeeded, but result.user was nil.")
////                }
////                
////                goToLogin = true
////                print("DEBUG: Navigating to login.")
//////                viewModel.changeName(new_Name: newName)
//////                viewModel.changeUserType(type: selectedOption)
//////                viewModel.changeEmail(user_email: newEmail)
//////                viewModel.userSave()
////            }
////        }
////    }
//
//    func validateEmailAddress(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
//    }
//}

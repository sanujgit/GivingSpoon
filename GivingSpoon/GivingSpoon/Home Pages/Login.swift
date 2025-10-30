//
//  Login.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Login: View {
    @StateObject var dataManager: DataManager = DataManager()
    @StateObject var viewModel: SignupViewModel = SignupViewModel()
    @State private var isSignedUp: Bool = false
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var pass: String = ""
    @State public var hasAccount: Bool = false
    @State private var showAlert: Bool = false
    @State private var switchToHome: Bool = false
    @State private var isLoading: Bool = false
    @State private var loggedIn: Bool = false
    @State private var showResetAlert: Bool = false
    @State private var resetEmail: String = ""
    @State private var resetMessage: String = ""

    var body: some View {
        if isLoading {
            ZStack {
                Color(hex: "#FFF6EE")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#E14C22")))
                        .scaleEffect(1.8)

                    Text("Loading...")
                        .foregroundColor(Color(hex: "#E14C22"))
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                }
            }
        } else if hasAccount {
            if viewModel.userType == "Donor" {
                DonorPostings(userEmail: $email, loggedIn: $loggedIn)
            } else if viewModel.userType == "Beneficiary" {
                BHomeNew(userEmail: $email, userAddress: $viewModel.address)
            } else if viewModel.userType == "Volunteer" {
                VolunteerHome(userEmail: $email)
            }
        } else {
            loginView
                .navigate(to: HomeView(), when: $switchToHome)
        }
    }

    var loginView: some View {
        ZStack {
            Color(hex: "#FFF6EE")
                .ignoresSafeArea()

            VStack {
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

                Text("Login")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))
                    .padding(.bottom, 5)

                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 340, height: 55)
                        .background(Color.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Password", text: $pass)
                        .padding()
                        .frame(width: 340, height: 55)
                        .background(Color.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 5, x: 0, y: 2)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                }
                .padding(.top, 30)
                
                HStack {
                    Spacer()
                    Button(action: {
                        resetEmail = email
                        if resetEmail.isEmpty {
                            resetMessage = "Please enter your email first."
                        } else {
                            Auth.auth().sendPasswordReset(withEmail: resetEmail) { error in
                                if let error = error {
                                    resetMessage = error.localizedDescription
                                } else {
                                    resetMessage = "A password reset link has been sent to \(resetEmail)."
                                }
                            }
                        }
                        showResetAlert = true
                    }) {
                        Text("Forgot Password?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#E14C22"))
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 50)
                
                Spacer()

                Button(action: LogIn) {
                    Text("Log in")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .frame(width: 320, height: 60)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color(hex: "#E14C22").opacity(0.9), Color(hex: "#E14C22")]), startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "#E14C22").opacity(0.3), radius: 6, x: 2, y: 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .alert("Email/password is incorrect.", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }
        .alert(isPresented: $showResetAlert) {
            Alert(title: Text("Password Reset"), message: Text(resetMessage), dismissButton: .default(Text("OK")))
        }
    }


    func LogIn() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: pass) { result, error in
            if error != nil {
                print(error!.localizedDescription)
                showAlert = true
                isLoading = false
            } else {
                dataManager.fetchUsers()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let user = dataManager.users.first(where: { $0.email == email }) {
                        viewModel.changeName(new_Name: user.name)
                        viewModel.changeUserType(type: user.userType)
                        viewModel.changeEmail(user_email: user.email)
                        viewModel.changeAddress(new_Address: user.address)
                        hasAccount = true
                        isLoading = false
                    } else {
                        print("User not found in users list.")
                        isLoading = false
                        showAlert = true
                    }
                }
            }
        }
    }
}

//
//  HomeView.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct HomeView: View {
    @State var showHome = false
    @State var loggedIn = false
    @State var email = ""

    var body: some View {
        NavigationView {
            if showHome {
                SignUp(showHome: $showHome, email: $email, loggedIn: $loggedIn)
            } else {
                HomeScreenView(showHome: $showHome, loggedIn: $loggedIn, email: $email)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HomeScreenView: View {
    @Binding var showHome: Bool
    @Binding var loggedIn: Bool
    @Binding var email: String
    @State private var switchToSignUp = false
    @State private var switchToLogin = false

    var body: some View {
        ZStack {
            Color(hex: "#FFF6EE")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Welcome to the GivingSpoon!")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 40) { // can switch back to 20
                    Button(action: {
                        showHome = true
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 22, design: .serif))
                            .foregroundColor(.white)
                            .frame(width: 300, height: 55)
                            .background(Color(hex: "#E14C22"))
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "#E14C22").opacity(0.4), radius: 5, x: 0, y: 5)
                    }

                    Button(action: {
                        switchToLogin = true
                    }) {
                        Text("Log In")
                            .font(.system(size: 22, design: .serif))
                            .foregroundColor(Color(hex: "#E14C22"))
                            .frame(width: 300, height: 55)
                            .background(Color.white)
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "#E14C22"), lineWidth: 2)
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "#E14C22").opacity(0.1), radius: 3, x: 0, y: 3)
                    }
                }
            }
        }
        // .navigate(to: SignUp(showHome: $showHome, email: $email, loggedIn: $loggedIn), when: $switchToSignUp)
        .navigate(to: Login(), when: $switchToLogin)
        .background(Color.clear)
    }
}

func goToSignUp() {}
func goToLogIn() {}

extension View {
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        ZStack {
            self
            NavigationLink(
                destination: view
                    .navigationBarTitle("")
                    .navigationBarHidden(true),
                isActive: binding
            ) {
                EmptyView()
            }
        }
    }
}

//#Preview {
//    HomeView()
//}

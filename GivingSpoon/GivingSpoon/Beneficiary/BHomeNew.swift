//
//  BHomeNew.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct BHomeNew: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @ObservedObject var viewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @State var showInfo = false
    @State var posting: Posting? = nil
    @Binding var userEmail: String
    @Binding var userAddress: String
    @State var switchScreen = false
    
    var body: some View {
        if showInfo, let selectedPosting = posting{
            BPostingInfo(showInfo: $showInfo, post: .constant(selectedPosting), userEmail: $userEmail, userAddress: $userAddress)
        }
        else {
            BHomeTabView(
                bHomeModel: bHomeModel,
                showInfo: $showInfo,
                selectedPosting: $posting,
                userEmail: $userEmail,
                userAddress: $userAddress,
                switchScreen: $switchScreen
            )
                .onAppear(perform: {
                    printCheck()
                    dataManager.fetchUsers()
                })
                .navigate(to: HomeView(), when: $switchScreen)
        }
    }
    
    func printCheck() {
        print("THE EMAIL IS: " + viewModel.email)
        print("THE ADDRESS IS: " + viewModel.address)
    }
}

struct BHomeTabView: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @StateObject var viewModel: SignupViewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    
    @Binding var showInfo: Bool
    @Binding var selectedPosting: Posting?
    @Binding var userEmail: String
    @Binding var userAddress: String
    @Binding var switchScreen: Bool

    var body: some View {
        ZStack {
            TabView {
                BPostingsNew(
                    bHomeModel: bHomeModel,
                    showInfo: $showInfo,
                    selectedPosting: $selectedPosting
                )
                    .tabItem {
                        Label("Available Food", systemImage: "carrot")
                    }

                BHistoryNew(userEmail: $userEmail)
                    .tabItem {
                        Label("My Claims", systemImage: "calendar")
                    }

                BSettingsNew(userEmail: $userEmail, switchScreen: $switchScreen)
                    .tabItem {
                        Label("Settings", systemImage: "person.fill")
                    }
            }
            .accentColor(Color(hex: "#E14C22"))
            .navigationBarHidden(true)
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Color(hex: "#F3E9FE"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear {
                // bHomeModel.locationManager.delegate = bHomeModel
                // bHomeModel.locationManager.requestWhenInUseAuthorization()
                dataManager.fetchUsers()
            }
            
            if bHomeModel.noLocation {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    Text("Please enable location access.")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width - 100, height: 120)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .transition(.opacity)
            }
        }
    }
}

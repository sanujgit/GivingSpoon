//
//  DonorPostings.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct DonorPostings: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @ObservedObject var viewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @Binding var userEmail: String
    @State var showDonor = false
    @State var switchScreen = false
    @Binding var loggedIn: Bool
    
    var body: some View {
        if switchScreen {
            HomeView()
        }
        else if showDonor{
            DonationInfo(showDonor: $showDonor, userEmail: $userEmail)
        }
        else {
            DonorTabView(showDonor: $showDonor, userEmail: $userEmail, switchScreen: $switchScreen, loggedIn: $loggedIn)
                .onAppear(perform: {
                    printCheck()
                    dataManager.fetchUsers()
                })
        }
    }
    
    func printCheck() {
        print("THE ADDRESS IS: " + viewModel.address)
    }
}

struct DonorTabView: View {
    @ObservedObject var viewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @Binding var showDonor: Bool
    @Binding var userEmail: String
    @Binding var switchScreen: Bool
    @Binding var loggedIn: Bool
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Current Postings
            DonorHistory(showDonor: $showDonor, userEmail: $userEmail)
                .tabItem {
                    VStack {
                        Image(systemName: "tray.full.fill")
                        Text("My Postings")
                    }
                }
                .tag(0)

            // Past Donations (NEW)
            DonorPast(userEmail: $userEmail)
                .tabItem {
                    VStack {
                        Image(systemName: "clock.fill")
                        Text("Past")
                    }
                }
                .tag(1)

            // Settings
            DonorSettings(userEmail: $userEmail, switchScreen: $switchScreen, loggedIn: $loggedIn)
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#E14C22"))
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor(Color(hex: "#FFF6EE"))
            UITabBar.appearance().unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.6)
            dataManager.fetchUsers()
        }
    }
}

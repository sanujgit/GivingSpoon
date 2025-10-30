//
//  VolunteerHome.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct VolunteerHome: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @ObservedObject var viewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @State var showInfo = false
    @State var posting: Posting? = nil
    @Binding var userEmail: String
    @State var switchScreen = false
    @State var switchToMap: Bool = false
    @State var cameFromHistory: Bool = false
    @State var selectedTab: Int = 0
    
    var body: some View {
        if showInfo, let selectedPosting = posting{
            VolunteerPostingInfo(
                post: Binding(get: { posting! }, set: { posting = $0 }),
                bHomeModel: bHomeModel,
                showInfo: $showInfo,
                userEmail: $userEmail,
                switchToMap: $switchToMap,
                cameFromHistory: $cameFromHistory,
                selectedTab: $selectedTab
            )
        }
        else {
            VolunteerTabView(showInfo: $showInfo, selectedPosting: $posting, userEmail: $userEmail, switchScreen: $switchScreen, cameFromHistory: $cameFromHistory, selectedTab: $selectedTab)
                .onAppear(perform: {
                    printCheck()
                    dataManager.fetchUsers()
                })
                .navigate(to: HomeView(), when: $switchScreen)
        }
    }
    
    func printCheck() {
        print("THE ADDRESS IS: " + viewModel.address)
    }
}

struct VolunteerTabView: View {
    @Binding var showInfo: Bool
    @StateObject var dataManager: DataManager = DataManager()
    @Binding var selectedPosting: Posting?
    @Binding var userEmail: String
    @Binding var switchScreen: Bool
    @Binding var cameFromHistory: Bool
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Available Deliveries
            VolunteerPostings(showInfo: $showInfo, userEmail: $userEmail, selectedPosting: $selectedPosting, cameFromHistory: $cameFromHistory)
                .tag(0)
                .tabItem {
                    Label("Available", systemImage: "list.dash")
                }

            // Tab 1: Current Deliveries
            VolunteerHistory(showInfo: $showInfo, selectedPosting: $selectedPosting, userEmail: $userEmail, cameFromHistory: $cameFromHistory)
                .tag(1)
                .tabItem {
                    Label("Current", systemImage: "calendar")
                }

            // Tab 2: Past Deliveries
            VolunteerPast(userEmail: $userEmail)
                .tag(2)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            // Tab 3: Settings
            VolunteerSettings(userEmail: $userEmail, switchScreen: $switchScreen)
                .tag(3)
                .tabItem {
                    Label("Settings", systemImage: "person.fill")
                }
        }
        .navigationBarHidden(true)
        .onAppear {
            dataManager.fetchUsers()
        }
        .accentColor(Color(hex: "#E14C22"))
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color(hex: "#F3E9FE"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

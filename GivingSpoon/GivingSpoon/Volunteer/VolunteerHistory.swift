//
//  VolunteerHistory.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation

struct VolunteerHistory: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @ObservedObject var viewModel: SignupViewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @Binding var showInfo: Bool
    @Binding var selectedPosting: Posting?
    @Binding var userEmail: String
    @Binding var cameFromHistory: Bool

    init(showInfo: Binding<Bool>, selectedPosting: Binding<Posting?>, userEmail: Binding<String>, cameFromHistory: Binding<Bool>) {
        self._showInfo = showInfo
        self._selectedPosting = selectedPosting
        self._userEmail = userEmail
        self._cameFromHistory = cameFromHistory

        // Match nav bar appearance to cream background
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 1.0, green: 0.9647, blue: 0.9333, alpha: 1) // #FFF6EE
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF6EE").ignoresSafeArea()

                VStack {
                    headerView()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 25) {
                            ForEach(bHomeModel.your_vol_data) { posting in
                                postingCard(for: posting)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear(perform: loadData)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func headerView() -> some View {
        HStack {
            Text("My Current Deliveries")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))
            Spacer()
        }
        .padding()
    }

    private func postingCard(for posting: Posting) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            PostingView(
                post: posting,
                statusMessage: "",
                showDeleteButton: false,
                deleteAction: {},
                userLocation: bHomeModel.userLocation
            )

            HStack {
                Spacer()
                seeMoreInfoButton(for: posting)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#E14C22").opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 6, x: 0, y: 4)
        .padding(.vertical, 8)
    }

    private func seeMoreInfoButton(for posting: Posting) -> some View {
        Button(action: {
            cameFromHistory = true
            selectedPosting = posting
            showInfo = true
        }) {
            Text("See more info")
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color(hex: "#E14C22"))
                .cornerRadius(10)
        }
    }

    private func loadData() {
        bHomeModel.locationManager.delegate = bHomeModel
        dataManager.users.forEach { user in
            if user.email == userEmail {
                viewModel.changeName(new_Name: user.name)
                viewModel.changeUserType(type: user.userType)
                viewModel.changeEmail(user_email: user.email)
            }
        }
        bHomeModel.fetchVolData()
        bHomeModel.fetchYourVolData(volEmail: userEmail)
    }
}

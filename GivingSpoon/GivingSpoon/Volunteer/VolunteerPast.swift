//
//  VolunteerPast.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation

struct VolunteerPast: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @ObservedObject var viewModel: SignupViewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @Binding var userEmail: String

    @State private var animatedCount = 0

    init(userEmail: Binding<String>) {
        self._userEmail = userEmail
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 1.0, green: 0.9647, blue: 0.9333, alpha: 1)
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF6EE").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    headerView()
                        .padding(.top, 10)

                    Text("Number of deliveries made: \(animatedCount)")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .onChange(of: completedDeliveries.count) { newCount in
                            animateCountUp(to: newCount)
                        }

                    if completedDeliveries.isEmpty {
                        Text("No past deliveries yet.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                            .padding(.horizontal)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 25) {
                                ForEach(completedDeliveries) { posting in
                                    postingCard(for: posting)
                                }
                            }
                            .padding(.top, 10)
                            .padding(.horizontal)
                        }
                        .scrollContentBackground(.hidden)
                    }

                    Spacer()
                }
            }
            .onAppear {
                loadData()
                animateCountUp(to: completedDeliveries.count)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }


    private var completedDeliveries: [Posting] {
        bHomeModel.your_vol_data.filter {
            !$0.item_dropped.isEmpty && $0.item_deliverer == userEmail
        }
    }

    private func animateCountUp(to target: Int) {
        animatedCount = 0
        let duration = 0.6
        let steps = min(target, 50)

        guard steps > 0 else {
            animatedCount = target
            return
        }

        let interval = duration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (interval * Double(i))) {
                animatedCount = Int(Double(i) / Double(steps) * Double(target))
            }
        }
    }

    private func headerView() -> some View {
        HStack {
            Text("Past Deliveries")
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

    private func loadData() {
        print("Loading volunteer data for: \(userEmail)")
        dataManager.fetchUsers()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let user = dataManager.users.first(where: { $0.email == userEmail }) {
                viewModel.changeName(new_Name: user.name)
                viewModel.changeUserType(type: user.userType)
                viewModel.changeEmail(user_email: user.email)

                bHomeModel.fetchVolData()
                bHomeModel.fetchCompletedVolunteerDeliveries(volEmail: userEmail)
            }
        }

        bHomeModel.locationManager.delegate = bHomeModel
    }
}

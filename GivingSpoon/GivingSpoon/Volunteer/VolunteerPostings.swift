//
//  VolunteerPostings.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation

struct VolunteerPostings: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @Binding var showInfo: Bool
    @Binding var userEmail: String
    @Binding var selectedPosting: Posting?
    @State private var showSparkles = false
    @Binding var cameFromHistory: Bool

    var sortedVolunteerPostings: [Posting] {
        guard let userLocation = bHomeModel.userLocation else {
            return []
        }

        return bHomeModel.vol_data
            .filter { post in
                guard let lat = post.item_lat, let long = post.item_long, lat != 0.0, long != 0.0 else {
                    return false
                }
                let distance = CLLocation(latitude: lat, longitude: long).distance(from: userLocation) / 1609.34
                return distance <= 50
            }
            .sorted { a, b in
                let distA = CLLocation(latitude: a.item_lat ?? 0.0, longitude: a.item_long ?? 0.0).distance(from: userLocation)
                let distB = CLLocation(latitude: b.item_lat ?? 0.0, longitude: b.item_long ?? 0.0).distance(from: userLocation)
                return distA < distB
            }
    }

    init(showInfo: Binding<Bool>, userEmail: Binding<String>, selectedPosting: Binding<Posting?>, cameFromHistory: Binding<Bool>) {
        self._showInfo = showInfo
        self._userEmail = userEmail
        self._selectedPosting = selectedPosting
        self._cameFromHistory = cameFromHistory

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

                VStack {
                    headerView()

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach(sortedVolunteerPostings) { posting in
                                if shouldDisplay(posting) {
                                    postingCard(for: posting)
                                }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal)
                    }
                    .refreshable {
                        refreshData()
                    }
                    .scrollContentBackground(.hidden)
                }

                if showInfo, let selectedPosting = selectedPosting {
                    VolunteerPostingInfo(
                        post: Binding(
                            get: { selectedPosting },
                            set: { newVal in self.selectedPosting = newVal }
                        ),
                        bHomeModel: bHomeModel,
                        // viewModel: bHomeModel,
                        showInfo: $showInfo,
                        // showAlert: .constant(false),
                        userEmail: $userEmail,
                        switchToMap: .constant(false),
                        cameFromHistory: $cameFromHistory,
                        selectedTab: .constant(0)
                    )
                }
            }
            .onAppear(perform: loadData)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func headerView() -> some View {
        HStack {
            Text("Available Deliveries")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))
            Spacer()
        }
        .padding([.horizontal, .top])
    }

    private func postingCard(for posting: Posting) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            PostingView(
                post: posting,
                statusMessage: "A donation awaits your help!",
                showDeleteButton: false,
                deleteAction: {},
                userLocation: bHomeModel.userLocation
            )

            HStack {
                Spacer()
                seeMoreInfoButton(for: posting)
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.vertical, 8)
    }

    private func seeMoreInfoButton(for posting: Posting) -> some View {
        ZStack {
            Button(action: {
                showSparkles = true
                cameFromHistory = false
                selectedPosting = posting
                showInfo = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showSparkles = false
                }
            }) {
                Text("See more info")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "#E14C22"))
                    .cornerRadius(10)
            }

            if showSparkles {
                SparkleOverlay()
                    .frame(width: 60, height: 30)
                    .transition(.opacity)
            }
        }
    }

    private func shouldDisplay(_ posting: Posting) -> Bool {
        return !posting.item_donEmail.isEmpty &&
               !posting.item_benEmail.isEmpty &&
               posting.item_claimed.isEmpty
    }

    private func loadData() {
        bHomeModel.locationManager.delegate = bHomeModel
        bHomeModel.locationManager.requestWhenInUseAuthorization()
        bHomeModel.locationManager.startUpdatingLocation()
        bHomeModel.fetchVolData()
    }

    private func refreshData() {
        bHomeModel.fetchVolData()
    }
}


struct SparkleOverlay: View {
    @State private var sparkles: [UUID] = []

    var body: some View {
        ZStack {
            ForEach(sparkles, id: \.self) { id in
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 6, height: 6)
                    .position(
                        x: CGFloat.random(in: 0...60),
                        y: CGFloat.random(in: 0...30)
                    )
                    .opacity(0.7)
                    .scaleEffect(0.5)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

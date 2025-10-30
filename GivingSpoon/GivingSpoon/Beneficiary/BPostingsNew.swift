//
//  BPostingsNew.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
// import SDWebImageSwiftUI
import CoreLocation

struct BPostingsNew: View {
    @StateObject var dataManager: DataManager = DataManager()
    @ObservedObject var viewModel: SignupViewModel = SignupViewModel()
    @ObservedObject var bHomeModel: BeneficiaryViewModel
    @Binding var showInfo: Bool
    @Binding var selectedPosting: Posting?
    @State private var isRefreshing = false
    @State private var hasLoaded = false

    var filteredPostings: [Posting] {
        guard let userLocation = bHomeModel.userLocation else {
            return []
        }

        return bHomeModel.all_ben_data
            .filter { post in
                guard let lat = post.item_lat, let long = post.item_long,
                      lat != 0.0, long != 0.0 else { return false }

                let postLoc = CLLocation(latitude: lat, longitude: long)
                let distanceMiles = postLoc.distance(from: userLocation) / 1609.34
                return distanceMiles <= 50
            }
            .sorted { a, b in
                let aLoc = CLLocation(latitude: a.item_lat ?? 0.0, longitude: a.item_long ?? 0.0)
                let bLoc = CLLocation(latitude: b.item_lat ?? 0.0, longitude: b.item_long ?? 0.0)
                return aLoc.distance(from: userLocation) < bLoc.distance(from: userLocation)
            }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF6EE").ignoresSafeArea()

                VStack {
                    headerView()

                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#E14C22")))
                            .padding(.top, 10)
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            if filteredPostings.isEmpty {
                                Text("No nearby donations found.")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                            } else {
                                ForEach(filteredPostings) { posting in
                                    postingCard(posting)
                                }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await refreshData()
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                bHomeModel.startTrackingLocation()
                print("DEBUG: Top-level view appeared.")
                print("DEBUG: userLocation = \(String(describing: bHomeModel.userLocation))")
                print("DEBUG: all_ben_data count = \(bHomeModel.all_ben_data.count)")
                bHomeModel.locationManager.delegate = bHomeModel
                bHomeModel.locationManager.requestWhenInUseAuthorization()
                bHomeModel.locationManager.startUpdatingLocation()
                bHomeModel.fetchAllBenData()
            }
            .onChange(of: bHomeModel.userLocation) { newLocation in
                if newLocation != nil && !hasLoaded {
                    hasLoaded = true
                    bHomeModel.fetchAllBenData()
                    print("Location set, re-fetching postings.")
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func headerView() -> some View {
        HStack {
            Text("Available Food Items")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))
            Spacer()
        }
        .padding()
    }
    
    private func postingCard(_ posting: Posting) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card content
            VStack(alignment: .leading, spacing: 10) {
                PostingView(
                    post: posting,
                    statusMessage: "",
                    showDeleteButton: false,
                    deleteAction: {},
                    userLocation: bHomeModel.userLocation
                )

                if let userLoc = bHomeModel.userLocation,
                   let postLat = posting.item_lat,
                   let postLong = posting.item_long,
                   postLat != 0.0, postLong != 0.0 {

                    let postingLocation = CLLocation(latitude: postLat, longitude: postLong)
                    let distanceInMiles = postingLocation.distance(from: userLoc) / 1609.34
                    Text(String(format: " %.1f miles away", distanceInMiles))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                } else {
                    Text("📍 Distance not available")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }

                // Expiry date
                Text("Expires: \(posting.item_expiryDate.formattedAsDonationDate)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
            .onAppear {
                bHomeModel.fetchAllBenData()
                print("DEBUG: forced fetch on appear")
                print("DEBUG: all_ben_data count = \(bHomeModel.all_ben_data.count)")
                for post in bHomeModel.all_ben_data {
                    print("DEBUG: Posting: \(post.item_name), lat: \(post.item_lat ?? -1), long: \(post.item_long ?? -1)")
                }
                print("DEBUG: Authorization status = \(CLLocationManager().authorizationStatus.rawValue)")
            }

            // Accept button
            Button {
                self.showInfo = true
                selectedPosting = posting
                print("showInfo: ", self.showInfo)
            } label: {
                Text("Click to Accept")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(hex: "#E14C22"))
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 8)
    }

//    private func postingCard(_ posting: Posting) -> some View {
//        ZStack(alignment: .bottomTrailing) {
//            VStack(alignment: .leading, spacing: 10) {
//                PostingView(
//                    post: posting,
//                    statusMessage: "",
//                    showDeleteButton: false,
//                    deleteAction: {},
//                    userLocation: bHomeModel.userLocation
//                )
//
//                if let userLoc = bHomeModel.userLocation,
//                   let postLat = posting.item_lat,
//                   let postLong = posting.item_long,
//                   postLat != 0.0, postLong != 0.0 {
//
//                    let postingLocation = CLLocation(latitude: postLat, longitude: postLong)
//                    let distanceInMiles = postingLocation.distance(from: userLoc) / 1609.34
////                    Text(String(format: "%.1f miles away", distanceInMiles))
////                        .font(.caption)
////                        .foregroundColor(.gray)
////                        .padding(.top, 4)
//                } else {
//                    Text("Distance not available")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .padding(.top, 4)
//                }
//            }
//            .padding()
//            .onAppear {
//                bHomeModel.fetchAllBenData()
//                print("DEBUG: forced fetch on appear")
//                print("DEBUG: all_ben_data count = \(bHomeModel.all_ben_data.count)")
//                for post in bHomeModel.all_ben_data {
//                    print("DEBUG: Posting: \(post.item_name), lat: \(post.item_lat ?? -1), long: \(post.item_long ?? -1)")
//                }
//                print("DEBUG: Authorization status = \(CLLocationManager().authorizationStatus.rawValue)")
//            }
////            .onAppear {
////                let lat = posting.item_lat ?? -1
////                let long = posting.item_long ?? -1
////                print("DEBUG: Posting '\(posting.item_name)' coords: lat = \(lat), long = \(long)")
////            }
//            .background(Color.white)
//            .cornerRadius(16)
//            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
//
//            Button {
//                self.showInfo = true
//                selectedPosting = posting
//                print("showInfo: ", self.showInfo)
//            } label: {
//                Text("Click to accept")
//                    .foregroundColor(.white)
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 20)
//                    .background(Color(hex: "#E14C22"))
//                    .cornerRadius(10)
//            }
//            .padding(15)
//        }
//        .padding(.vertical, 8)
//    }

    private func refreshData() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        bHomeModel.fetchAllBenData()
        isRefreshing = false
    }
}

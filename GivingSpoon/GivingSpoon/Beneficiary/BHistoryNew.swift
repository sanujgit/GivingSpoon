//
//  BHistoryNew.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation

struct BHistoryNew: View {
    @ObservedObject var viewModel: SignupViewModel = SignupViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @Binding var userEmail: String
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF6EE").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView()
                    
                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#E14C22")))
                            .padding(.top, 10)
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            ForEach($bHomeModel.ben_data) { $posting in
                                // Only show postings that are not dropped and have a donor
                                if posting.item_dropped.isEmpty && !posting.item_donEmail.isEmpty {
                                    postingCard($posting)
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await refreshData()
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear(perform: loadData)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // Header
    private func headerView() -> some View {
        HStack {
            Text("My Current Claims")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))
            Spacer()
        }
        .padding([.horizontal, .top])
    }

    // Posting Card
    private func postingCard(_ posting: Binding<Posting>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            PostingView(
                post: posting.wrappedValue,
                statusMessage: getStatusMessage(for: posting.wrappedValue),
                showDeleteButton: false,
                deleteAction: {},
                userLocation: bHomeModel.userLocation
            )
            
            // Distance display
            if let userLoc = bHomeModel.userLocation,
               let lat = posting.wrappedValue.item_lat,
               let long = posting.wrappedValue.item_long,
               lat != 0.0, long != 0.0 {
                
                let postingLoc = CLLocation(latitude: lat, longitude: long) // lat and long are now non-optional
                let distanceInMiles = postingLoc.distance(from: userLoc) / 1609.34
                
                Text(String(format: "%.1f miles away", distanceInMiles))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            // Self-pickup confirmation checkbox
            if posting.item_pickupSelf.wrappedValue == true {
                HStack {
                    Button(action: {
                        markAsPickedUp(posting)
                    }) {
                        Label(
                            posting.item_picked.wrappedValue.isEmpty ? "I picked this up" : "Picked up!",
                            systemImage: posting.item_picked.wrappedValue.isEmpty ? "square" : "checkmark.square.fill"
                        )
                        .foregroundColor(posting.item_picked.wrappedValue.isEmpty ? .blue : .green)
                    }
                    .disabled(!posting.item_picked.wrappedValue.isEmpty)
                }
                .padding(.top, 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
        .padding(.vertical, 6)
    }

    // Status Messages
    private func getStatusMessage(for posting: Posting) -> String {
        if posting.item_pickupSelf == true && posting.item_picked.isEmpty {
            return "The food is ready for you to pick up!"
        } else if posting.item_claimed.isEmpty {
            return "A volunteer has not chosen your order yet."
        } else if posting.item_picked.isEmpty {
            return "A volunteer is on their way to pick up your order."
        } else if posting.item_dropped.isEmpty {
            return "A volunteer is on their way to drop off your food."
        } else {
            return ""
        }
    }

    // Firestore Update
    private func markAsPickedUp(_ posting: Binding<Posting>) {
        bHomeModel.markPostingAsPickedUp(posting: posting.wrappedValue) { success in
            if success {
                DispatchQueue.main.async {
                    posting.wrappedValue.item_picked = "self"
                }
            } else {
                print("Failed to mark posting as picked up")
            }
        }
    }

    // Load Data
    private func loadData() {
        dataManager.fetchUsers()
        dataManager.users.forEach { user in
            if user.email == userEmail {
                viewModel.changeName(new_Name: user.name)
                viewModel.changeUserType(type: user.userType)
                viewModel.changeEmail(user_email: user.email)
            }
        }
        bHomeModel.locationManager.delegate = bHomeModel
        bHomeModel.fetchBenData(beneEmail: userEmail)
    }

    // MARK: Refresh
    private func refreshData() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loadData()
        isRefreshing = false
    }
}


//import SwiftUI
//import CoreLocation
//
//struct BHistoryNew: View {
//    @ObservedObject var viewModel: SignupViewModel = SignupViewModel()
//    @StateObject var dataManager: DataManager = DataManager()
//    @StateObject var bHomeModel = BeneficiaryViewModel()
//    @Binding var userEmail: String
//    @State private var isRefreshing = false
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(hex: "#FFF6EE").ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    headerView()
//                    
//                    if isRefreshing {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#E14C22")))
//                            .padding(.top, 10)
//                    }
//                    
//                    ScrollView(.vertical, showsIndicators: false) {
//                        VStack(spacing: 20) {
//                            ForEach(bHomeModel.ben_data) { posting in
//                                if posting.item_dropped.isEmpty && !posting.item_donEmail.isEmpty {
//                                    postingCard(posting)
//                                }
//                            }
//                        }
//                        .padding(.top)
//                        .padding(.horizontal)
//                    }
//                    .refreshable {
//                        await refreshData()
//                    }
//                    .scrollContentBackground(.hidden)
//                }
//            }
//            .onAppear(perform: loadData)
//            .toolbar(.hidden, for: .navigationBar)
//        }
//    }
//
//    // MARK: Header
//    private func headerView() -> some View {
//        HStack {
//            Text("My Current Claims")
//                .font(.system(size: 36, weight: .bold, design: .serif))
//                .foregroundColor(Color(hex: "#E14C22"))
//            Spacer()
//        }
//        .padding([.horizontal, .top])
//    }
//
//    // MARK: Posting Card
//    private func postingCard(_ posting: Posting) -> some View {
//        VStack(alignment: .leading, spacing: 12) {
//            PostingView(
//                post: posting,
//                statusMessage: getStatusMessage(for: posting),
//                showDeleteButton: false,
//                deleteAction: {},
//                userLocation: bHomeModel.userLocation
//            )
//            
//            // Distance display
//            if let userLoc = bHomeModel.userLocation,
//               let lat = posting.item_lat,
//               let long = posting.item_long,
//               lat != 0.0, long != 0.0 {
//                let postingLoc = CLLocation(latitude: lat, longitude: long)
//                let distanceInMiles = postingLoc.distance(from: userLoc) / 1609.34
//                Text(String(format: "%.1f miles away", distanceInMiles))
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.top, 4)
//            }
//            
//            // Self-pickup confirmation checkbox
//            HStack {
//                Button(action: {
//                    if posting.item_picked.isEmpty {
//                        markAsPickedUp(posting)
//                    }
//                }) {
//                    Label(
//                        posting.item_picked.isEmpty ? "I picked this up" : "Picked up!",
//                        systemImage: posting.item_picked.isEmpty ? "square" : "checkmark.square.fill"
//                    )
//                    .foregroundColor(posting.item_picked.isEmpty ? .blue : .green)
//                }
//                .disabled(!posting.item_picked.isEmpty) // prevent re-tapping after picked up
//            }
//            .padding(.top, 6)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
//        .padding(.vertical, 6)
//    }
//
//    // MARK: Status Messages
//    private func getStatusMessage(for posting: Posting) -> String {
//        if posting.item_pickupSelf == true {
//            return "The food is ready for you to pick up!"
//        } else if posting.item_claimed.isEmpty {
//            return "A volunteer has not chosen your order yet."
//        } else if posting.item_picked.isEmpty {
//            return "A volunteer is on their way to pick up your order."
//        } else if posting.item_dropped.isEmpty {
//            return "A volunteer is on their way to drop off your food."
//        } else {
//            return ""
//        }
//    }
//
//    // MARK: Firestore Update
//    private func markAsPickedUp(_ posting: Posting) {
//        // Update Firestore so this posting is considered "picked up"
//        bHomeModel.markPostingAsPickedUp(posting: posting) { success in
//            if success {
//                loadData()
//            } else {
//                print("Failed to mark posting as picked up")
//            }
//        }
//    }
//
//    // MARK: Load Data
//    private func loadData() {
//        dataManager.fetchUsers()
//        dataManager.users.forEach { user in
//            if user.email == userEmail {
//                viewModel.changeName(new_Name: user.name)
//                viewModel.changeUserType(type: user.userType)
//                viewModel.changeEmail(user_email: user.email)
//            }
//        }
//        bHomeModel.locationManager.delegate = bHomeModel
//        bHomeModel.fetchBenData(beneEmail: userEmail)
//    }
//
//    // MARK: Refresh
//    private func refreshData() async {
//        isRefreshing = true
//        try? await Task.sleep(nanoseconds: 1_000_000_000)
//        loadData()
//        isRefreshing = false
//    }
//}

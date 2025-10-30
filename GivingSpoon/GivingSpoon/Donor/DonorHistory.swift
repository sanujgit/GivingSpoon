//
//  DonorHistory.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct DonorHistory: View {
    @StateObject var dataManager: DataManager = DataManager()
    @ObservedObject var viewModel: SignupViewModel = SignupViewModel()
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @Binding var showDonor: Bool
    @Binding var userEmail: String
    // @State var showAlert: Bool = false
    // @State var postingToDelete: String? = nil

    var body: some View {
        ZStack {
            Color(hex: "#FFF6EE").ignoresSafeArea()

            VStack(spacing: 0) {
                headerView()
                
                List {
                    ForEach(bHomeModel.donor_Postings.filter { $0.item_picked.isEmpty && !$0.item_donEmail.isEmpty }) { posting in
                        postingCard(posting)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    bHomeModel.deletePosting(postingID: posting.id)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        bHomeModel.fetchDonorData(donorEmail: userEmail)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .padding(.top, 10)

//                ScrollView {
//                    VStack(spacing: 20) {
//                        ForEach(bHomeModel.donor_Postings) { posting in
//                            if posting.item_picked.isEmpty && !posting.item_donEmail.isEmpty {
//                                postingCard(posting)
//                            }
//                        }
//                    }
//                    .padding(.top)
//                    .padding(.horizontal)
//                }
//                .refreshable {
//                    refreshData()
//                }
            }
            .onAppear(perform: loadData)
//            .alert("Are you sure you want to delete?", isPresented: $showAlert) {
//                Button("Yes", role: .destructive) {
//                    if let postingID = postingToDelete {
//                        bHomeModel.updateDonEmail(itemDonEmail: "", posting_id: postingID)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                            bHomeModel.fetchDonorData(donorEmail: userEmail)
//                        }
//                    }
//                }
//                Button("Cancel", role: .cancel) { }
//            }
        }
    }

    private func headerView() -> some View {
        HStack {
            Text("My Donations")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))

            Spacer()

            Button(action: {
                self.showDonor = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(10)
                    .background(Color(hex: "#F35B04"))
                    .clipShape(Circle())
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
            }
        }
        .padding([.horizontal, .top])
    }
    
    private func postingCard(_ posting: Posting) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            PostingView(
                post: posting,
                statusMessage: getStatusMessage(for: posting),
                showDeleteButton: false,
                deleteAction: {}
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
        .padding(.horizontal)
        .padding(.vertical, 6)
    }



//    private func postingCard(_ posting: Posting) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            PostingView(
//                post: posting,
//                statusMessage: getStatusMessage(for: posting),
//                showDeleteButton: posting.item_claimed.isEmpty,
//                deleteAction: {
//                    postingToDelete = posting.id
//                    showAlert = true
//                }
//            )
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(18)
//        .overlay(
//            RoundedRectangle(cornerRadius: 18)
//                .stroke(Color(hex: "#E14C22").opacity(0.25), lineWidth: 1)
//        )
//        .shadow(color: Color.orange.opacity(0.1), radius: 6, x: 0, y: 4)
//        .padding(.horizontal)
//    }

    private func getStatusMessage(for posting: Posting) -> String {
        // 1) Self-pickup case
        if posting.item_pickupSelf == true {
            return "Someone will pick it up soon!"
        }
        // 2) No beneficiary yet
        else if posting.item_benAddress.isEmpty {
            return "No one has claimed your donation yet."
        }
        // 3) Beneficiary claimed but no volunteer assigned yet
        else if posting.item_claimed.isEmpty {
            return "✨ A volunteer will pick this up soon."
        }
        // 4) Volunteer on the way
        else {
            return "🚗 A volunteer is on the way!"
        }
    }


    private func loadData() {
        print("Loading donor data for: \(userEmail)")
        dataManager.fetchUsers()
        dataManager.users.forEach { user in
            if user.email == userEmail {
                viewModel.changeName(new_Name: user.name)
                viewModel.changeUserType(type: user.userType)
                viewModel.changeEmail(user_email: user.email)
            }
        }
        bHomeModel.locationManager.delegate = bHomeModel
        bHomeModel.fetchDonorData(donorEmail: userEmail)
    }

    private func refreshData() {
        bHomeModel.fetchDonorData(donorEmail: userEmail)
        dataManager.fetchUsers()
    }
}



//
//  VolunteerPostingInfo.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
// import SDWebImageSwiftUI
import FirebaseFirestore

struct VolunteerPostingInfo: View {
    @Binding var post: Posting
    @ObservedObject var bHomeModel: BeneficiaryViewModel
    // @StateObject var viewModel: SignupViewModel = SignupViewModel()
    @Binding var showInfo: Bool
    // @State var showAlert: Bool = false
    @Binding var userEmail: String
    @Binding var switchToMap: Bool
    @Binding var cameFromHistory: Bool
    @Binding var selectedTab: Int
    @State private var refreshTrigger = UUID()
    @State private var postVersion = UUID()
    
    func startListeningToPost() {
        let db = Firestore.firestore()
        db.collection("Postings").document(post.id).addSnapshotListener { snapshot, error in
            guard let document = snapshot, document.exists,
                  let data = try? document.data(as: Posting.self) else {
                print("Failed to fetch updated posting")
                if let doc = snapshot {
                    print("Raw data:", doc.data() ?? "nil")
                } else {
                    print("Document doesn't exist or snapshot is nil")
                }
                return
            }

            self.post = data
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "#FFF6EE").ignoresSafeArea()

            VStack(spacing: 20) {
                headerView()
                postingDetailsList()
                Spacer()
                todoButtons()
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .id(refreshTrigger)
    }

    private func headerView() -> some View {
        HStack {
            Button(action: {
                showInfo = false
                if cameFromHistory {
                    selectedTab = 1
                } else {
                    selectedTab = 0
                }
                cameFromHistory = false
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: "#E14C22"))
                    .font(.system(size: 22, weight: .medium))
                    .padding(8)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            Text("Posting Info")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))
                .padding(.leading, 10)

            Spacer()
        }
        .padding(.top, 20)
    }

    private func postingDetailsList() -> some View {
        VStack(spacing: 15) {
            detailRow(icon: "cart.fill", title: "Item Name", value: post.item_name)
            Divider().background(Color.gray.opacity(0.3))
            detailRow(icon: "info.circle.fill", title: "Details", value: post.item_details)
            Divider().background(Color.gray.opacity(0.3))
            detailRow(icon: "person.fill", title: "Donor", value: post.item_donor)
            Divider().background(Color.gray.opacity(0.3))
            addressRow(icon: "location.fill", title: "Donor Address", value: post.item_address) {
                bHomeModel.openAddressInMaps(address: post.item_address)
            }
            Divider().background(Color.gray.opacity(0.3))
            addressRow(icon: "location.fill", title: "Beneficiary Address", value: post.item_benAddress) {
                bHomeModel.openAddressInMaps(address: post.item_benAddress)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#E14C22"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#E14C22"))
                Text(value)
                    .font(.body)
                    .foregroundColor(.black)
            }
            Spacer()
        }
    }

    private func addressRow(icon: String, title: String, value: String, action: @escaping () -> Void) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#E14C22"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#E14C22"))
                Text(value)
                    .font(.body)
                    .foregroundColor(.black)
            }
            Spacer()

            Button(action: action) {
                Text("Open in Maps")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#E14C22"))
                    .underline()
            }
        }
    }

    private func todoButtons() -> some View {
        VStack(spacing: 16) {
            StepRow(
                label: "1. Deliver",
                isCompleted: post.item_claimed != "",
                isEnabled: post.item_claimed == "",
                onTap: {
                    post = post.updatedClaimed("claimed", deliverer: userEmail)
                    bHomeModel.updatePost(itemDeliverer: userEmail, posting_id: post.id)
                    bHomeModel.updateClaimed(itemClaimed: "claimed", posting_id: post.id)
                    // bHomeModel.updatePicked(itemPicked: "picked", posting_id: post.id)
                    refreshPost()
                    refreshTrigger = UUID()
                }
            )

            StepRow(
                label: "2. Picked Up",
                isCompleted: post.item_picked != "",
                isEnabled: post.item_claimed != "" && post.item_picked == "",
                onTap: {
                    post = post.updatedPicked("picked")
                    bHomeModel.updatePicked(itemPicked: "picked", posting_id: post.id)
                    // bHomeModel.updatePicked(itemPicked: "picked", posting_id: post.id)
                    refreshPost()
                    refreshTrigger = UUID()
                }
            )

            StepRow(
                label: "3. Dropped Off",
                isCompleted: post.item_dropped != "",
                isEnabled: post.item_picked != "" && post.item_dropped == "",
                onTap: {
                    post = post.updatedDropped("dropped")
                    bHomeModel.updateDropped(itemDropped: "dropped", posting_id: post.id)
                    refreshPost()
                    refreshTrigger = UUID()
                }
            )

            if post.item_deliverer != "" && post.item_picked == "" {
                Button {
                    post = post.resetDelivery()
                    showInfo = false
                    bHomeModel.updatePost(itemDeliverer: "", posting_id: post.id)
                    bHomeModel.updateClaimed(itemClaimed: "", posting_id: post.id)
                    bHomeModel.updatePicked(itemPicked: "", posting_id: post.id)
                    refreshPost()
                    refreshTrigger = UUID()
                } label: {
                    Text("Cancel Delivery")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#E14C22"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E14C22"), lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
                .padding(.top, 12)
            }
        }
    }

    private func StepRow(label: String, isCompleted: Bool, isEnabled: Bool, onTap: @escaping () -> Void) -> some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.title2)

            Text(label)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(.black)

            Spacer()

            if isEnabled && !isCompleted {
                Button("Mark as Done") {
                    onTap()
                }
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#E14C22"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    func switchInfo() {
        showInfo.toggle()
    }
    
    func refreshPost() {
        let db = Firestore.firestore()
        db.collection("Postings").document(post.id).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    if let data = document.data() {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let updatedPost = try JSONDecoder().decode(Posting.self, from: jsonData)
                        self.post = updatedPost
                    }
                } catch {
                    print("Error decoding updated post: \(error)")
                }
            } else {
                print("Document does not exist or error: \(String(describing: error))")
            }
        }
    }
}

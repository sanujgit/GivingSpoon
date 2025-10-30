//
//  BPostingsInfo.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
// import SDWebImageSwiftUI

struct BPostingInfo: View {
    @StateObject var viewModel: SignupViewModel = SignupViewModel()
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @Binding var showInfo: Bool
    @State var showAlert: Bool = false
    @State var showPickupChoiceAlert: Bool = false
    @Binding var post: Posting
    @Binding var userEmail: String
    @Binding var userAddress: String
    @State private var tempAddress: String = ""
    @State private var showAddressRequiredAlert: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "#FFF6EE").ignoresSafeArea()

            VStack(spacing: 20) {
                headerView()

                postingDetailsList()

                Spacer()

                actionButtons()
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
        .alert("Address Required", isPresented: $showAddressRequiredAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a drop-off address to send a volunteer.")
        }
    }

    private func headerView() -> some View {
        HStack {
            Text("Posting Info")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#E14C22"))
            Spacer()
        }
        .padding(.top, 20)
    }

    private func postingDetailsList() -> some View {
        VStack(spacing: 15) {
            detailRow(icon: "cart.fill", title: "Item Name", value: post.item_name)
            Divider().background(Color.black.opacity(0.1))
            detailRow(icon: "info.circle.fill", title: "Details", value: post.item_details)
            Divider().background(Color.black.opacity(0.1))
            detailRow(icon: "person.fill", title: "Donor", value: post.item_donor)
            Divider().background(Color.black.opacity(0.1))
            detailRow(icon: "location.fill", title: "Address", value: post.item_address)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#E14C22"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
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

    private func actionButtons() -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Drop-off Address (required for volunteer delivery)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#E14C22"))

                TextField("Enter drop-off address", text: $tempAddress)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            }

            Button {
                // Always allow claim
                showPickupChoiceAlert = true
            } label: {
                Text("Claim")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundColor(.white)
                    .background(Color(hex: "#E14C22"))
                    .cornerRadius(12)
            }
            .alert("How would you like to get your item?", isPresented: $showPickupChoiceAlert) {
                Button("I’ll pick it up myself") {
                    post.item_benEmail = userEmail
                    bHomeModel.updateEmail(itemEmail: userEmail, posting_id: post.id)
                    bHomeModel.updatePickupSelf(posting_id: post.id, pickupSelf: true)
                    // Close this screen and go back
                    showInfo = false
                }

                Button("Send a volunteer") {
                    let addressTrimmed = tempAddress.trimmingCharacters(in: .whitespaces)
                    if addressTrimmed.isEmpty {
                        showAddressRequiredAlert = true
                    } else {
                        post.item_benEmail = userEmail
                        post.item_benAddress = addressTrimmed
                        bHomeModel.updateEmail(itemEmail: userEmail, posting_id: post.id)
                        bHomeModel.updateBenAddress(itemBenAddress: addressTrimmed, posting_id: post.id)
                        bHomeModel.updatePickupSelf(posting_id: post.id, pickupSelf: false)
                        // Close this screen and go back
                        showInfo = false
                    }
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Do you want to pick it up yourself or have a volunteer deliver it?")
            }

            Button {
                showInfo = false
            } label: {
                Text("Cancel")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .foregroundColor(Color(hex: "#E14C22"))
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E14C22"), lineWidth: 2)
                    )
                    .cornerRadius(12)
            }
        }
    }
}



//import SwiftUI
//// import SDWebImageSwiftUI
//
//struct BPostingInfo: View {
//    @StateObject var viewModel: SignupViewModel = SignupViewModel()
//    @StateObject var bHomeModel = BeneficiaryViewModel()
//    @Binding var showInfo: Bool
//    @State var showAlert: Bool = false
//    @State var showPickupChoiceAlert: Bool = false
//    @Binding var post: Posting
//    @Binding var userEmail: String
//    @Binding var userAddress: String
//    @State private var tempAddress: String = ""
//
//    var body: some View {
//        ZStack {
//            Color(hex: "#FFF6EE").ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                headerView()
//
//                postingDetailsList()
//
//                Spacer()
//
//                actionButtons()
//                    .padding(.bottom, 30)
//            }
//            .padding(.horizontal, 20)
//        }
//    }
//
//    private func headerView() -> some View {
//        HStack {
//            Text("Posting Info")
//                .font(.system(size: 36, weight: .bold, design: .serif))
//                .foregroundColor(Color(hex: "#E14C22"))
//            Spacer()
//        }
//        .padding(.top, 20)
//    }
//
//    private func postingDetailsList() -> some View {
//        VStack(spacing: 15) {
//            detailRow(icon: "cart.fill", title: "Item Name", value: post.item_name)
//            Divider().background(Color.black.opacity(0.1))
//            detailRow(icon: "info.circle.fill", title: "Details", value: post.item_details)
//            Divider().background(Color.black.opacity(0.1))
//            detailRow(icon: "person.fill", title: "Donor", value: post.item_donor)
//            Divider().background(Color.black.opacity(0.1))
//            detailRow(icon: "location.fill", title: "Address", value: post.item_address)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
//    }
//
//    private func detailRow(icon: String, title: String, value: String) -> some View {
//        HStack(alignment: .top, spacing: 10) {
//            Image(systemName: icon)
//                .foregroundColor(Color(hex: "#E14C22"))
//                .frame(width: 30)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(Color(hex: "#E14C22"))
//
//                Text(value)
//                    .font(.body)
//                    .foregroundColor(.black)
//            }
//
//            Spacer()
//        }
//    }
//
//    private func actionButtons() -> some View {
//        VStack(spacing: 16) {
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Drop-off Address")
//                    .font(.headline)
//                    .foregroundColor(Color(hex: "#E14C22"))
//
//                TextField("Enter drop-off address", text: $tempAddress)
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
//            }
//    
//            Button {
//                guard !tempAddress.trimmingCharacters(in: .whitespaces).isEmpty else {
//                    return
//                }
//                showPickupChoiceAlert = true
//            } label: {
//                Text("Claim")
//                    .font(.system(size: 24, weight: .bold, design: .serif))
//                    .frame(maxWidth: .infinity, minHeight: 60)
//                    .foregroundColor(.white)
//                    .background(tempAddress.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color(hex: "#E14C22"))
//                    .cornerRadius(12)
//            }
//            .disabled(tempAddress.trimmingCharacters(in: .whitespaces).isEmpty)
//            .alert("How would you like to get your item?", isPresented: $showPickupChoiceAlert) {
//                Button("I’ll pick it up myself") {
//                    post.item_benEmail = userEmail
//                    bHomeModel.updateEmail(itemEmail: userEmail, posting_id: post.id)
//                    bHomeModel.updatePickupSelf(posting_id: post.id, pickupSelf: true)
//                    showAlert = true
//                }
//                Button("Send a volunteer") {
//                    post.item_benEmail = userEmail
//                    post.item_benAddress = tempAddress
//                    bHomeModel.updateEmail(itemEmail: userEmail, posting_id: post.id)
//                    bHomeModel.updateBenAddress(itemBenAddress: tempAddress, posting_id: post.id)
//                    bHomeModel.updatePickupSelf(posting_id: post.id, pickupSelf: false)
//                    showAlert = true
//                }
//                Button("Cancel", role: .cancel) {}
//            } message: {
//                Text("Do you want to pick it up yourself or have a volunteer deliver it?")
//            }
//
//            
//            Button {
//                showInfo = false
//            } label: {
//                Text("Cancel")
//                    .font(.system(size: 24, weight: .bold, design: .serif))
//                    .frame(maxWidth: .infinity, minHeight: 60)
//                    .foregroundColor(Color(hex: "#E14C22"))
//                    .background(Color.white)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color(hex: "#E14C22"), lineWidth: 2)
//                    )
//                    .cornerRadius(12)
//            }
//        }
//    }
//
//    private func switchInfo() {
//        showInfo.toggle()
//    }
//}

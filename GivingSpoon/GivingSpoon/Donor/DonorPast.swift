//
//  DonorPast.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct DonorPast: View {
    @Binding var userEmail: String
    @StateObject private var bHomeModel = BeneficiaryViewModel()
    @State private var animatedCount: Int = 0

    var body: some View {
        ZStack {
            Color(hex: "#FFF6EE").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Past Donations")
                    .padding(.leading, 20)
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))
                
                // Count-up animated number
                Text("Number of donations made: \(animatedCount)")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .onChange(of: bHomeModel.donor_Past_Postings.count) { newCount in
                        animateCountUp(to: newCount)
                    }
                    .padding(.leading, 20)

                if bHomeModel.donor_Past_Postings.isEmpty {
                    Spacer()
                    VStack {
                        Text("No past donations yet.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                else {
//                    List {
//                        ForEach(bHomeModel.donor_Past_Postings) { posting in
//                            VStack(alignment: .leading) {
//                                Text("✅ \(posting.item_name)")
//                                Text("📦 Picked: \(posting.item_picked)")
//                                Text("📅 Expiry: \(posting.item_expiryDate.formattedAsDonationDate)")
//                            }
//                            .background(Color.yellow.opacity(0.2))
//                        }
//                    }
//                    .listStyle(.plain)
                    
                    List {
                        ForEach(bHomeModel.donor_Past_Postings) { posting in
                            PostingView(
                                post: posting,
                                statusMessage: "",
                                showDeleteButton: false,
                                deleteAction: {}
                            )
                            .padding(.vertical, 6)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                bHomeModel.fetchDonorPastData(donorEmail: userEmail)
                animateCountUp(to: bHomeModel.donor_Past_Postings.count)
            }
        }
    }

    // Helper animation function
    private func animateCountUp(to target: Int) {
        animatedCount = 0
        let duration: Double = 0.5
        let stepTime = duration / Double(max(target, 1))

        for i in 0...target {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepTime * Double(i)) {
                withAnimation(.easeOut(duration: 0.1)) {
                    animatedCount = i
                }
            }
        }
    }
}

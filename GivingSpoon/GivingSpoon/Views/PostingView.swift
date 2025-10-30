//
//  PostingView.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation

struct PostingView: View {
    var post: Posting
    var statusMessage: String
    var showDeleteButton: Bool
    var deleteAction: () -> Void
    var userLocation: CLLocation?

    // Compute distance once here
    var distanceMilesText: String? {
        guard
            let userLocation = userLocation,
            let lat = post.item_lat,
            let long = post.item_long,
            lat != 0.0, long != 0.0
        else {
            return nil
        }

        let postLocation = CLLocation(latitude: lat, longitude: long)
        let distanceMeters = userLocation.distance(from: postLocation)
        let distanceMiles = distanceMeters / 1609.34
        return String(format: "%.1f miles away", distanceMiles)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(post.item_name) (\(post.item_quantity))")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.black)

                    Text("Donor: \(post.item_donor)")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.gray)
                }

                Spacer()

                if showDeleteButton {
                    Button(action: deleteAction) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
            }

            // Middle Details
            if !post.item_details.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "leaf")
                        .foregroundColor(Color(hex: "#E14C22"))
                    Text(post.item_details)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(.black)
                }
            }
            
            // Show distance text if available
            if let distanceText = distanceMilesText {
                Text(distanceText)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.gray)
            }

            Text("Expires on: \(formattedDate(from: post.item_expiryDate))")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.gray)

            // Status
            HStack(spacing: 8) {
                Text(statusMessage)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "#E14C22"))
            }
        }
    }
    
    func formattedDate(from date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        outputFormatter.timeStyle = .none
        return outputFormatter.string(from: date)
    }
}

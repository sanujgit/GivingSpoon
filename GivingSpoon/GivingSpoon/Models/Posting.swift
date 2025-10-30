//
//  Posting.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import FirebaseFirestore
import Foundation
import FirebaseCore

struct Posting: Identifiable, Codable {
    var id: String
    var item_name: String
    var item_details: String
    var item_image: String
    var item_donor: String
    var item_address: String
    var item_deliverer: String
    var item_beneficiary: String
    var item_benEmail: String
    var item_benAddress: String
    var item_donEmail: String
    var item_claimed: String
    var item_picked: String
    var item_dropped: String
    var item_quantity: String
    var item_lat: Double?
    var item_long: Double?
    var item_expiryDate: Date
    var item_pickupSelf: Bool

    // Big 8 allergens
    var containsPeanuts: Bool
    var containsTreeNuts: Bool
    var containsMilk: Bool
    var containsEggs: Bool
    var containsFish: Bool
    var containsShellfish: Bool
    var containsWheat: Bool
    var containsSoy: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case item_name
        case item_details
        case item_image
        case item_donor
        case item_address
        case item_deliverer
        case item_beneficiary
        case item_benEmail
        case item_benAddress
        case item_donEmail
        case item_claimed
        case item_picked
        case item_dropped
        case item_quantity
        case item_lat
        case item_long
        case item_expiryDate
        case item_pickupSelf
        case containsPeanuts
        case containsTreeNuts
        case containsMilk
        case containsEggs
        case containsFish
        case containsShellfish
        case containsWheat
        case containsSoy
    }

    init(
        id: String,
        item_name: String,
        item_details: String,
        item_image: String,
        item_donor: String,
        item_address: String,
        item_deliverer: String,
        item_beneficiary: String,
        item_benEmail: String,
        item_benAddress: String,
        item_donEmail: String,
        item_claimed: String,
        item_picked: String,
        item_dropped: String,
        item_quantity: String,
        item_lat: Double?,
        item_long: Double?,
        item_expiryDate: Date,
        item_pickupSelf: Bool = false,
        containsPeanuts: Bool = false,
        containsTreeNuts: Bool = false,
        containsMilk: Bool = false,
        containsEggs: Bool = false,
        containsFish: Bool = false,
        containsShellfish: Bool = false,
        containsWheat: Bool = false,
        containsSoy: Bool = false
    ) {
        self.id = id
        self.item_name = item_name
        self.item_details = item_details
        self.item_image = item_image
        self.item_donor = item_donor
        self.item_address = item_address
        self.item_deliverer = item_deliverer
        self.item_beneficiary = item_beneficiary
        self.item_benEmail = item_benEmail
        self.item_benAddress = item_benAddress
        self.item_donEmail = item_donEmail
        self.item_claimed = item_claimed
        self.item_picked = item_picked
        self.item_dropped = item_dropped
        self.item_quantity = item_quantity
        self.item_lat = item_lat
        self.item_long = item_long
        self.item_expiryDate = item_expiryDate
        self.item_pickupSelf = item_pickupSelf

        self.containsPeanuts = containsPeanuts
        self.containsTreeNuts = containsTreeNuts
        self.containsMilk = containsMilk
        self.containsEggs = containsEggs
        self.containsFish = containsFish
        self.containsShellfish = containsShellfish
        self.containsWheat = containsWheat
        self.containsSoy = containsSoy
    }
    
    func updatedClaimed(_ value: String, deliverer: String) -> Posting {
        var copy = self
        copy.item_claimed = value
        copy.item_deliverer = deliverer
        return copy
    }

    func updatedPicked(_ value: String) -> Posting {
        var copy = self
        copy.item_picked = value
        return copy
    }

    func updatedDropped(_ value: String) -> Posting {
        var copy = self
        copy.item_dropped = value
        return copy
    }

    func resetDelivery() -> Posting {
        var copy = self
        copy.item_deliverer = ""
        copy.item_claimed = ""
        copy.item_picked = ""
        copy.item_dropped = ""
        return copy
    }
    
    func updatedPickupSelf(_ value: Bool) -> Posting {
        var copy = self
        copy.item_pickupSelf = value
        return copy
    }
}

extension Date {
    var formattedAsDonationDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }
}

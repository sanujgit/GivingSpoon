//
//  DonationInfo.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DonationInfo: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    @StateObject var dataManager: DataManager = DataManager()
    @StateObject var viewModel: SignupViewModel = SignupViewModel()

    @State private var foodItem: String = ""
    @State private var details: String = ""
    @State private var quantity: String = ""
    @State private var address: String = ""
    @State private var showValidationAlert = false
    @State private var expiryDate: Date = Date()

    @Binding var showDonor: Bool
    @Binding var userEmail: String
    @State var showView = false
    @State var name: String = ""
    
    // Track allergen selections
    @State private var selectedAllergens: Set<String> = []

    private let allergens = [
        "Milk", "Eggs", "Fish", "Shellfish",
        "Tree Nuts", "Peanuts", "Wheat", "Soybeans"
    ]
    
    private func isFormValid() -> Bool {
        return !foodItem.trimmingCharacters(in: .whitespaces).isEmpty &&
               !quantity.trimmingCharacters(in: .whitespaces).isEmpty &&
               !details.trimmingCharacters(in: .whitespaces).isEmpty &&
               !address.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF6EE").ignoresSafeArea()

                VStack(spacing: 0) {
                    // back button
                    HStack {
                        Button(action: { showDonor = false }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(hex: "#E14C22"))
                                .font(.system(size: 22, weight: .medium))
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)

                    ScrollView {
                        VStack(spacing: 25) {
                            Text("What would you like to donate today?")
                                .font(.system(size: 26, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#E14C22"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            // Input fields
                            VStack(spacing: 18) {
                                CustomTextFieldStyled(title: "Food Item (bread, fries, etc.)", text: $foodItem)
                                CustomTextFieldStyled(title: "Quantity", text: $quantity)
                                CustomTextFieldStyled(title: "Dietary Info (vegan, nut-free, etc.)", text: $details)
                                CustomTextFieldStyled(title: "Address", text: $address)
                                DatePicker(
                                    "Expiry Date *",
                                    selection: $expiryDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .padding()
                                .frame(height: 55)
                                .background(Color.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: 350)

                            // Allergen checkboxes
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Big 8 Allergens *")
                                    .font(.system(size: 18, weight: .semibold, design: .serif))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)

                                ForEach(allergens, id: \.self) { allergen in
                                    AllergenCheckbox(
                                        allergen: allergen,
                                        isSelected: selectedAllergens.contains(allergen)
                                    ) {
                                        if selectedAllergens.contains(allergen) {
                                            selectedAllergens.remove(allergen)
                                        } else {
                                            selectedAllergens.insert(allergen)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: 350)
                            .padding(.top, 10)
                            .padding(.bottom, 80)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Post donation button
                    Button(action: {
                        if !isFormValid() {
                            showValidationAlert = true
                            return
                        }

                        let allergenInfo = selectedAllergens.joined(separator: ", ")
                        let finalDetails = details + (allergenInfo.isEmpty ? "" : " | Allergens: \(allergenInfo)")

                        // Geocode address
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(address) { placemarks, error in
                            if let placemark = placemarks?.first, let location = placemark.location {
                                let lat = location.coordinate.latitude
                                let long = location.coordinate.longitude

                                // Prepare Firestore data
                                let donorName = viewModel.name.isEmpty ? "Anonymous" : viewModel.name
                                let postingData: [String: Any] = [
                                    "item_name": foodItem,
                                    "item_details": finalDetails,
                                    "item_quantity": quantity,
                                    "item_address": address,
                                    "item_lat": lat,
                                    "item_long": long,
                                    "item_donEmail": userEmail,
                                    "item_donor": donorName,
                                    "item_claimed": "",
                                    "item_picked": "",
                                    "item_dropped": "",
                                    "item_deliverer": "",
                                    "item_beneficiary": "",
                                    "item_benEmail": "",
                                    "item_benAddress": "",
                                    "item_pickupSelf": false,
                                    "item_expiryDate": ISO8601DateFormatter().string(from: expiryDate),
                                    
                                    // Big 8 allergens
                                    "containsMilk": selectedAllergens.contains("Milk"),
                                    "containsEggs": selectedAllergens.contains("Eggs"),
                                    "containsFish": selectedAllergens.contains("Fish"),
                                    "containsShellfish": selectedAllergens.contains("Shellfish"),
                                    "containsTreeNuts": selectedAllergens.contains("Tree Nuts"),
                                    "containsPeanuts": selectedAllergens.contains("Peanuts"),
                                    "containsWheat": selectedAllergens.contains("Wheat"),
                                    "containsSoy": selectedAllergens.contains("Soybeans")
                                ]

                                // Write to Firestore
                                Firestore.firestore().collection("Postings").addDocument(data: postingData) { error in
                                    if let error = error {
                                        print("Failed to post donation: \(error.localizedDescription)")
                                    } else {
                                        print("Donation posted successfully")
                                        // Navigate back
                                        showDonor = false
                                    }
                                }
                            } else if let error = error {
                                print("Geocoding failed: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Post Donation")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: 350)
                            .padding()
                            .background(isFormValid() ? Color(hex: "#E14C22") : Color.gray)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .disabled(!isFormValid())
                    .alert("Missing Fields", isPresented: $showValidationAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please fill out all fields before posting the donation.")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if dataManager.users.isEmpty {
                dataManager.fetchUsers {
                    assignUserData()
                }
            } else {
                assignUserData()
            }
        }
    }
    
    func assignUserData() {
        // Find the user matching the logged-in email
        if let user = dataManager.users.first(where: { $0.email == userEmail }) {
            viewModel.name = user.name
            viewModel.userType = user.userType
            viewModel.email = user.email
            viewModel.address = user.address
        }
    }

}

struct AllergenCheckbox: View {
    let allergen: String
    var isSelected: Bool
    var toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .green : .gray)
                Text(allergen)
                    .foregroundColor(.black)
            }
            .font(.system(size: 16, weight: .medium, design: .serif))
        }
    }
}

struct CustomTextFieldStyled: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Label with red asterisk
            HStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.black)

                Text("*")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
            }

            // The actual text field
            TextField("", text: $text)
                .font(.system(size: 18, design: .serif))
                .padding()
                .frame(height: 55)
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#E14C22").opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}


//
//  BeneficiaryViewModel.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import CoreLocation
import Firebase
import FirebaseAuth
import UIKit
import MapKit
import FirebaseFirestore
// import FirebaseFirestoreSwift
 
// Fetching User Location...
class BeneficiaryViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
 
    @Published var locationManager = CLLocationManager()
    @Published var search = ""
    @Published var user_data: [User] = []
 
    // location details.....
    @Published var userLocation : CLLocation? = nil
    @Published var userAddress2 = ""
    @Published var noLocation = false
 
    // menu
    @Published var showMenu = false
    @Published var postings: [Posting] = []
    @Published var donor_Postings: [Posting] = []
    @Published var donor_Past_Postings: [Posting] = []
    
    // donor menu
    @Published var showDonorAdd = false
    
    // ben menu
    @Published var ben_data: [Posting] = []
    @Published var all_ben_data: [Posting] = []
    
    // vol menu
    @Published var vol_data: [Posting] = []
    @Published var your_vol_data: [Posting] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startTrackingLocation() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            print("Location access not determined. Requesting now...")
            locationManager.requestWhenInUseAuthorization() // triggers prompt
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Location access granted.")
            locationManager.startUpdatingLocation()
        } else {
            print("Location access denied/restricted.")
        }
    }
    
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let coord = placemarks?.first?.location?.coordinate {
                completion(coord)
            } else {
                print("Geocoding failed for address: \(address), error: \(error?.localizedDescription ?? "unknown")")
                completion(nil)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            print("User granted permission.")
            manager.startUpdatingLocation()
        }
    }

 
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        // checking location access...
//        switch manager.authorizationStatus {
//        case .authorizedWhenInUse:
//            print("authorized")
//            self.noLocation = false
//            manager.requestLocation()
//        case .denied:
//            print("denied")
//            self.noLocation = true
//        default:
//            print("unknown")
//            self.noLocation = false
//            // Direct Call
//            locationManager.requestWhenInUseAuthorization()
//            // Modifying Info.plist
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        self.userLocation = latestLocation
        print("User CLLocationManager update: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")
        self.extractLocation()
    }
    
    func extractLocation() {
        guard let location = self.userLocation else {
            print("No userLocation available")
            return
        }

        print("Reverse-geocoding location:", location.coordinate.latitude, location.coordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error:", error.localizedDescription)
                return
            }

            if let placemark = placemarks?.first {
                var address = ""
                if let name = placemark.name {
                    address += name
                }
                if let locality = placemark.locality {
                    address += ", \(locality)"
                }
                self.userAddress2 = address
                print("Final user address:", address)
            } else {
                print("No placemark found")
            }
        }
    }
    
    func fetchData() {
        let db = Firestore.firestore()
        db.collection("Postings").getDocuments(completion: { (snap, err) in
            guard let itemData = snap else { return }
            self.postings = itemData.documents.compactMap({ (doc) -> Posting? in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let lat = doc.get("item_lat") as? Double ?? 0.0
                let long = doc.get("item_long") as? Double ?? 0.0
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false
                return Posting(id: id, item_name: name, item_details: details, item_image: image, item_donor: donor, item_address: address, item_deliverer: deliverer, item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress, item_donEmail: donEmail, item_claimed: claimed, item_picked: picked, item_dropped: dropped, item_quantity: quantity, item_lat: lat, item_long: long, item_expiryDate: expiryDate, item_pickupSelf: pickupSelf, containsPeanuts: containsPeanuts, containsTreeNuts: containsTreeNuts, containsMilk: containsMilk, containsEggs: containsEggs, containsFish: containsFish, containsShellfish: containsShellfish, containsWheat: containsWheat, containsSoy: containsSoy)
            })
        })
    }
    
    func fetchDonorData(donorEmail: String) {
        let db = Firestore.firestore()
        db.collection("Postings").getDocuments(completion: { (snap, err) in
            guard let itemData = snap else { return }
            self.donor_Postings = itemData.documents.compactMap({ (doc) -> Posting? in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let lat = doc.get("item_lat") as? Double ?? 0.0
                let long = doc.get("item_long") as? Double ?? 0.0
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false

                // Check if the post is expired
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let expiry = calendar.startOfDay(for: expiryDate)
                let isExpired = expiry < today

                print("\n this is donEmail " + donEmail)
                print("this is the donorEmail " + donorEmail + "\n")

                if donorEmail == donEmail && picked == "" && !isExpired {
                    print("posting added")
                    return Posting(
                        id: id,
                        item_name: name,
                        item_details: details,
                        item_image: image,
                        item_donor: donor,
                        item_address: address,
                        item_deliverer: deliverer,
                        item_beneficiary: beneficiary,
                        item_benEmail: benEmail,
                        item_benAddress: benAddress,
                        item_donEmail: donEmail,
                        item_claimed: claimed,
                        item_picked: picked,
                        item_dropped: dropped,
                        item_quantity: quantity,
                        item_lat: lat,
                        item_long: long,
                        item_expiryDate: expiryDate,
                        item_pickupSelf: pickupSelf,
                        containsPeanuts: containsPeanuts,
                        containsTreeNuts: containsTreeNuts,
                        containsMilk: containsMilk,
                        containsEggs: containsEggs,
                        containsFish: containsFish,
                        containsShellfish: containsShellfish,
                        containsWheat: containsWheat,
                        containsSoy: containsSoy
                    )
                } else {
                    print("posting not added (maybe expired)")
                    return nil
                }
            })
        })
    }


//    func fetchDonorData(donorEmail: String) {
//        let db = Firestore.firestore()
//        db.collection("Postings").getDocuments(completion: { (snap, err) in
//            guard let itemData = snap else { return }
//            self.donor_Postings = itemData.documents.compactMap({ (doc) -> Posting? in
//                let id = doc.documentID
//                let name = doc.get("item_name") as? String ?? ""
//                let image = doc.get("item_image") as? String ?? ""
//                let details = doc.get("item_details") as? String ?? ""
//                let donor = doc.get("item_donor") as? String ?? ""
//                let address = doc.get("item_address") as? String ?? ""
//                let deliverer = doc.get("item_deliverer") as? String ?? ""
//                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
//                let benEmail = doc.get("item_benEmail") as? String ?? ""
//                let benAddress = doc.get("item_benAddress") as? String ?? ""
//                let donEmail = doc.get("item_donEmail") as? String ?? ""
//                let claimed = doc.get("item_claimed") as? String ?? ""
//                let picked = doc.get("item_picked") as? String ?? ""
//                let dropped = doc.get("item_dropped") as? String ?? ""
//                let quantity = doc.get("item_quantity") as? String ?? ""
//                let lat = doc.get("item_lat") as? Double ?? 0.0
//                let long = doc.get("item_long") as? Double ?? 0.0
//                let expiryString = doc.get("item_expiryDate") as? String ?? ""
//                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
//                print("\n this is donEmail " + donEmail)
//                print("this is the donorEmail " + donorEmail + "\n")
//                if donorEmail == donEmail && picked == "" {
//                    print("posting added")
//                    return Posting(id: id, item_name: name, item_details: details, item_image: image, item_donor: donor, item_address: address, item_deliverer: deliverer, item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress, item_donEmail: donEmail, item_claimed: claimed, item_picked: picked, item_dropped: dropped, item_quantity: quantity, item_lat: lat, item_long: long, item_expiryDate: expiryDate)
//                } else {
//                    print("posting not added")
//                    return nil
//                }
//            })
//        })
//    }
    
    func fetchBenData(beneEmail: String) {
        let db = Firestore.firestore()
        db.collection("Postings").getDocuments(completion: { [weak self] (snap, err) in
            guard let self = self else { return }
            guard let itemData = snap else { return }
            
            self.ben_data = itemData.documents.compactMap { doc -> Posting? in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let lat = doc.get( "item_lat") as? Double ?? 0.0
                let long = doc.get( "item_long") as? Double ?? 0.0
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false
                print("\n this is name " + name)
                print("\n this is donEmail " + donEmail)
                print("this is the benEmail " + benEmail + "\n")
                
                if beneEmail == benEmail {
                    return Posting(id: id, item_name: name, item_details: details, item_image: image, item_donor: donor, item_address: address, item_deliverer: deliverer, item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress, item_donEmail: donEmail, item_claimed: claimed, item_picked: picked, item_dropped: dropped, item_quantity: quantity, item_lat: lat, item_long: long, item_expiryDate: expiryDate, item_pickupSelf: pickupSelf, containsPeanuts: containsPeanuts,
                                   containsTreeNuts: containsTreeNuts,
                                   containsMilk: containsMilk,
                                   containsEggs: containsEggs,
                                   containsFish: containsFish,
                                   containsShellfish: containsShellfish,
                                   containsWheat: containsWheat,
                                   containsSoy: containsSoy)
                } else {
                    return nil
                }
            }
            
            // After ben_data is set, geocode missing postings
            for i in 0..<self.ben_data.count {
                let posting = self.ben_data[i]
                
                // Assuming Posting has optional item_lat and item_long as Doubles
                if posting.item_lat == nil || posting.item_long == nil {
                    self.geocodeAddress(posting.item_address) { coord in
                        guard let coord = coord else { return }
                        
                        DispatchQueue.main.async {
                            self.ben_data[i].item_lat = coord.latitude
                            self.ben_data[i].item_long = coord.longitude
                        }
                    }
                }
            }
        })
    }
    
    func fetchAllBenData() {
        print("ENTERING fetchAllBenData")
        let db = Firestore.firestore()
        db.collection("Postings").getDocuments { snapshot, error in
            if let error = error {
                print("❌ ERROR fetching postings: \(error)")
                return
            }
            guard let docs = snapshot?.documents else {
                print("⚠️ No documents found.")
                return
            }

            print("Fetched \(docs.count) postings from Firestore.")

            // Loop through raw docs for debugging BEFORE filtering
            for doc in docs {
                print("---- RAW DOC START ----")
                print("Doc ID: \(doc.documentID)")
                print("Raw data: \(doc.data())")
                print("item_lat (raw):", doc.get("item_lat") ?? "nil")
                print("item_long (raw):", doc.get("item_long") ?? "nil")
                print("item_expiryDate (raw):", doc.get("item_expiryDate") ?? "nil")
                print("---- RAW DOC END ----\n")
            }

            self.all_ben_data = docs.compactMap { doc -> Posting? in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false

                // Expiry check
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let expiry = calendar.startOfDay(for: expiryDate)
                let isExpired = expiry < today

                // Parse latitude
                let lat: Double
                if let latValue = doc.get("item_lat") {
                    if let number = latValue as? NSNumber {
                        lat = number.doubleValue
                    } else if let string = latValue as? String, let doubleVal = Double(string) {
                        lat = doubleVal
                    } else {
                        lat = 0.0
                    }
                } else {
                    lat = 0.0
                }

                // Parse longitude
                let long: Double
                if let longValue = doc.get("item_long") {
                    if let number = longValue as? NSNumber {
                        long = number.doubleValue
                    } else if let string = longValue as? String, let doubleVal = Double(string) {
                        long = doubleVal
                    } else {
                        long = 0.0
                    }
                } else {
                    long = 0.0
                }

                if donEmail != "" && benEmail == "" && !isExpired {
                    return Posting(
                        id: id,
                        item_name: name,
                        item_details: details,
                        item_image: image,
                        item_donor: donor,
                        item_address: address,
                        item_deliverer: deliverer,
                        item_beneficiary: beneficiary,
                        item_benEmail: benEmail,
                        item_benAddress: benAddress,
                        item_donEmail: donEmail,
                        item_claimed: claimed,
                        item_picked: picked,
                        item_dropped: dropped,
                        item_quantity: quantity,
                        item_lat: lat,
                        item_long: long,
                        item_expiryDate: expiryDate,
                        item_pickupSelf: pickupSelf,
                        containsPeanuts: containsPeanuts,
                        containsTreeNuts: containsTreeNuts,
                        containsMilk: containsMilk,
                        containsEggs: containsEggs,
                        containsFish: containsFish,
                        containsShellfish: containsShellfish,
                        containsWheat: containsWheat,
                        containsSoy: containsSoy
                    )
                } else {
                    print("Posting skipped (donEmail empty, benEmail not empty, or expired).")
                    return nil
                }
            }

            print("Final filtered postings count: \(self.all_ben_data.count)")
        }
    }
    
    func markPostingAsPickedUp(posting: Posting, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        let postingId = posting.id
        
        db.collection("Postings").document(postingId).updateData([
            "item_picked": "self",
            "item_dropped": "done"
        ]) { error in
            if let error = error {
                print("Failed to update posting: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Posting marked as picked up!")

                // Update local ben_data immediately
                if let index = self.ben_data.firstIndex(where: { $0.id == postingId }) {
                    self.ben_data[index].item_picked = "self"
                    self.ben_data[index].item_dropped = "done"
                }

                // Optionally still refresh from Firestore if you want to be sure
                // self.fetchBenData(beneEmail: posting.item_benEmail)

                completion(true)
            }
        }
    }

    
//    func fetchAllBenData() {
//        let db = Firestore.firestore()
//        db.collection("Postings").getDocuments(completion: { (snap, err) in
//            guard let itemData = snap else { return }
//            self.all_ben_data = itemData.documents.compactMap({ (doc) -> Posting? in
//                let id = doc.documentID
//                let name = doc.get("item_name") as? String ?? ""
//                let image = doc.get("item_image") as? String ?? ""
//                let details = doc.get("item_details") as? String ?? ""
//                let donor = doc.get("item_donor") as? String ?? ""
//                let address = doc.get("item_address") as? String ?? ""
//                let deliverer = doc.get("item_deliverer") as? String ?? ""
//                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
//                let benEmail = doc.get("item_benEmail") as? String ?? ""
//                let benAddress = doc.get("item_benAddress") as? String ?? ""
//                let donEmail = doc.get("item_donEmail") as? String ?? ""
//                let claimed = doc.get("item_claimed") as? String ?? ""
//                let picked = doc.get("item_picked") as? String ?? ""
//                let dropped = doc.get("item_dropped") as? String ?? ""
//                let quantity = doc.get("item_quantity") as? String ?? ""
//                let expiryString = doc.get("item_expiryDate") as? String ?? ""
//                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
//                let lat: Double
//                if let latValue = doc.get("item_lat") {
//                    if let number = latValue as? NSNumber {
//                        lat = number.doubleValue
//                    } else if let string = latValue as? String, let doubleVal = Double(string) {
//                        lat = doubleVal
//                    } else {
//                        lat = 0.0
//                    }
//                } else {
//                    lat = 0.0
//                }
//
//                let long: Double
//                if let longValue = doc.get("item_long") {
//                    if let number = longValue as? NSNumber {
//                        long = number.doubleValue
//                    } else if let string = longValue as? String, let doubleVal = Double(string) {
//                        long = doubleVal
//                    } else {
//                        long = 0.0
//                    }
//                } else {
//                    long = 0.0
//                }
//
//                print("Firestore lat/long raw:", doc.get("item_lat") ?? "nil", doc.get("item_long") ?? "nil")
//                print("Parsed lat/long:", lat, long)
//                if (donEmail != "" && benEmail == "") {
//                    return Posting(id: id, item_name: name, item_details: details, item_image: image, item_donor: donor, item_address: address, item_deliverer: deliverer, item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress, item_donEmail: donEmail, item_claimed: claimed, item_picked: picked, item_dropped: dropped, item_quantity: quantity, item_lat: lat, item_long: long, item_expiryDate: expiryDate)
//                } else {
//                    return nil
//                }
//            })
//        })
//    }
    
    func fetchVolData() {
        let db = Firestore.firestore()
        db.collection("Postings").getDocuments(completion: { (snap, err) in
            guard let itemData = snap else { return }
            self.vol_data = itemData.documents.compactMap({ (doc) -> Posting? in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false
                
                let lat: Double
                if let latValue = doc.get("item_lat") {
                    if let number = latValue as? NSNumber {
                        lat = number.doubleValue
                    } else if let string = latValue as? String, let doubleVal = Double(string) {
                        lat = doubleVal
                    } else {
                        lat = 0.0
                    }
                } else {
                    lat = 0.0
                }

                let long: Double
                if let longValue = doc.get("item_long") {
                    if let number = longValue as? NSNumber {
                        long = number.doubleValue
                    } else if let string = longValue as? String, let doubleVal = Double(string) {
                        long = doubleVal
                    } else {
                        long = 0.0
                    }
                } else {
                    long = 0.0
                }
                
                if benEmail != "" && pickupSelf == false {
                    return Posting(id: id, item_name: name, item_details: details, item_image: image, item_donor: donor, item_address: address, item_deliverer: deliverer, item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress, item_donEmail: donEmail, item_claimed: claimed, item_picked: picked, item_dropped: dropped, item_quantity: quantity, item_lat: lat, item_long: long, item_expiryDate: expiryDate, item_pickupSelf: pickupSelf, containsPeanuts: containsPeanuts,
                                   containsTreeNuts: containsTreeNuts,
                                   containsMilk: containsMilk,
                                   containsEggs: containsEggs,
                                   containsFish: containsFish,
                                   containsShellfish: containsShellfish,
                                   containsWheat: containsWheat,
                                   containsSoy: containsSoy)
                } else {
                    print("did not return this post")
                    return nil
                }
            })
        })
    }
    
    func fetchYourVolData(volEmail: String) {
        let db = Firestore.firestore()
        db.collection("Postings").getDocuments(completion: { (snap, err) in
            guard let itemData = snap else { return }
            self.your_vol_data = itemData.documents.compactMap({ (doc) -> Posting? in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false
                
                let lat: Double
                if let latValue = doc.get("item_lat") {
                    if let number = latValue as? NSNumber {
                        lat = number.doubleValue
                    } else if let string = latValue as? String, let doubleVal = Double(string) {
                        lat = doubleVal
                    } else {
                        lat = 0.0
                    }
                } else {
                    lat = 0.0
                }

                let long: Double
                if let longValue = doc.get("item_long") {
                    if let number = longValue as? NSNumber {
                        long = number.doubleValue
                    } else if let string = longValue as? String, let doubleVal = Double(string) {
                        long = doubleVal
                    } else {
                        long = 0.0
                    }
                } else {
                    long = 0.0
                }
                
                if deliverer == volEmail && dropped == "" {
                    return Posting(id: id, item_name: name, item_details: details, item_image: image, item_donor: donor, item_address: address, item_deliverer: deliverer, item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress, item_donEmail: donEmail, item_claimed: claimed, item_picked: picked, item_dropped: dropped, item_quantity: quantity, item_lat: lat, item_long: long, item_expiryDate: expiryDate, item_pickupSelf: pickupSelf, containsPeanuts: containsPeanuts,
                                   containsTreeNuts: containsTreeNuts,
                                   containsMilk: containsMilk,
                                   containsEggs: containsEggs,
                                   containsFish: containsFish,
                                   containsShellfish: containsShellfish,
                                   containsWheat: containsWheat,
                                   containsSoy: containsSoy)
                } else {
                    print("did not return this post")
                    return nil
                }
            })
        })
    }
    
    func addPosting(
        itemName: String,
        itemBeneficiary: String,
        itemImage: String,
        itemDetails: String,
        itemBenEmail: String,
        itemBenAddress: String,
        itemClaimed: String,
        itemDonEmail: String,
        itemAddress: String,
        itemDeliverer: String,
        itemDonor: String,
        itemDropped: String,
        itemPicked: String,
        itemQuantity: String,
        itemLat: Double?,
        itemLong: Double?,
        itemExpiryDate: Date,
        itemPickupSelf: Bool,
        containsPeanuts: Bool,
        containsTreeNuts: Bool,
        containsMilk: Bool,
        containsEggs: Bool,
        containsFish: Bool,
        containsShellfish: Bool,
        containsWheat: Bool,
        containsSoy: Bool
    ) {
        let isoFormatter = ISO8601DateFormatter()
        let expiryDateString = isoFormatter.string(from: itemExpiryDate)

        let postDict: [String: Any] = [
            "item_name": itemName,
            "item_beneficiary": itemBeneficiary,
            "item_image": itemImage,
            "item_details": itemDetails,
            "item_benEmail": itemBenEmail,
            "item_benAddress": itemBenAddress,
            "item_claimed": itemClaimed,
            "item_donEmail": itemDonEmail,
            "item_address": itemAddress,
            "item_deliverer": itemDeliverer,
            "item_donor": itemDonor,
            "item_dropped": itemDropped,
            "item_picked": itemPicked,
            "item_quantity": itemQuantity,
            "item_lat": itemLat ?? 0.0,
            "item_long": itemLong ?? 0.0,
            "item_expiryDateString": expiryDateString,
            "item_expiryDate": itemExpiryDate,
            "item_pickupSelf": itemPickupSelf,
            
            // Big 8 allergens as separate fields
            "containsPeanuts": containsPeanuts,
            "containsTreeNuts": containsTreeNuts,
            "containsMilk": containsMilk,
            "containsEggs": containsEggs,
            "containsFish": containsFish,
            "containsShellfish": containsShellfish,
            "containsWheat": containsWheat,
            "containsSoy": containsSoy
        ]

        let db = Firestore.firestore()
        let id = self.createID()
        let docRef = db.collection("Postings").document(id)
        docRef.setData(postDict) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written with ID: \(id)")
            }
        }
    }
    
    func createID() -> String {
        let uuid = UUID().uuidString
        return uuid
    }
    
    func updatePost(itemDeliverer: String, posting_id: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Postings").document(posting_id)
        docRef.setData(["item_deliverer": itemDeliverer], merge: true) { error in
            if let error = error {
                print("error writing document: \(error)")
            }
            else {
                print("document updated successfully")
            }
        }
    }
    
    func updateEmail(itemEmail: String, posting_id: String) {
        print("the id is: " + posting_id)
        print("the email is: " + itemEmail)
        let db = Firestore.firestore()
        let docRef = db.collection("Postings").document(posting_id)
        docRef.setData(["item_benEmail": itemEmail], merge: true) { error in
            if let error = error {
                print("error writing document: \(error)")
            }
            else {
                print("document updated successfully")
            }
        }
    }
    
    func updateBenAddress(itemBenAddress: String, posting_id: String) {
        print("the id is: " + posting_id)
        print("OMG the address is: " + itemBenAddress)
        let db = Firestore.firestore()
        let docRef = db.collection("Postings").document(posting_id)
        docRef.setData(["item_benAddress": itemBenAddress], merge: true) { error in
            if let error = error {
                print("error writing document: \(error)")
            }
            else {
                print("document updated successfully")
            }
        }
    }
    
    func updateDonEmail(itemDonEmail: String, posting_id: String, completion: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        db.collection("DonorPostings").document(posting_id).updateData([
            "item_donEmail": itemDonEmail
        ]) { error in
            if let error = error {
                print("Error updating donor email: \(error.localizedDescription)")
            } else {
                print("Successfully removed donor email")
                completion?()
            }
        }
    }
    
    func updateClaimed(itemClaimed: String, posting_id: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Postings").document(posting_id)
        docRef.setData(["item_claimed": itemClaimed], merge: true) { error in
            if let error = error {
                print("error writing document: \(error)")
            }
            else {
                print("document updated successfully")
            }
        }
    }
    
    func updatePicked(itemPicked: String, posting_id: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Postings").document(posting_id)
        docRef.setData(["item_picked": itemPicked], merge: true) { error in
            if let error = error {
                print("error writing document: \(error)")
            }
            else {
                print("document updated successfully")
            }
        }
    }
    
    func updateDropped(itemDropped: String, posting_id: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("Postings").document(posting_id)
        docRef.setData(["item_dropped": itemDropped], merge: true) { error in
            if let error = error {
                print("error writing document: \(error)")
            }
            else {
                print("document updated successfully")
            }
        }
    }
    
    func updatePickupSelf(posting_id: String, pickupSelf: Bool) {
        let db = Firestore.firestore()
        db.collection("Postings").document(posting_id).updateData([
            "item_pickupSelf": pickupSelf
        ]) { error in
            if let error = error {
                print("Error updating pickup_self: \(error)")
            }
        }
    }
    
    func getBenAddress(benEmail: String) {
        let db = Firestore.firestore()
        db.collection("Users").getDocuments(completion: { (snap, err) in
            guard let itemData = snap else { return }
            self.user_data = itemData.documents.compactMap({ (doc) -> User? in
                let id = doc.documentID
                let name = doc.get("name") as! String
                let address = doc.get("address") as! String
                let email = doc.get("email") as! String
                let password = doc.get("password") as! String
                let role = doc.get("role") as! String
                if benEmail == email {
                    return User(id: id, name: name, address: address, email: email, password: password, userType: role)
                } else {
                    print("did not return this user")
                    return nil
                }
            })
        })
    }

    func openAddressInMaps(address: String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?address=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }
    
    func deletePosting(postingID: String) {
        let db = Firestore.firestore()
        db.collection("Postings").document(postingID).delete { error in
            if let error = error {
                print("Error deleting posting: \(error.localizedDescription)")
            } else {
                print("Posting deleted successfully.")
            }
        }
    }
    
    func fetchCompletedVolunteerDeliveries(volEmail: String) {
        print("Fetching COMPLETED deliveries for: \(volEmail)")
        let db = Firestore.firestore()
        
        db.collection("Postings").getDocuments { (snap, err) in
            guard let itemData = snap else {
                print("No postings snapshot")
                return
            }

            self.your_vol_data = itemData.documents.compactMap { doc in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false
                
                let lat: Double
                if let latValue = doc.get("item_lat") {
                    if let number = latValue as? NSNumber {
                        lat = number.doubleValue
                    } else if let string = latValue as? String, let doubleVal = Double(string) {
                        lat = doubleVal
                    } else {
                        lat = 0.0
                    }
                } else {
                    lat = 0.0
                }

                let long: Double
                if let longValue = doc.get("item_long") {
                    if let number = longValue as? NSNumber {
                        long = number.doubleValue
                    } else if let string = longValue as? String, let doubleVal = Double(string) {
                        long = doubleVal
                    } else {
                        long = 0.0
                    }
                } else {
                    long = 0.0
                }

                if deliverer == volEmail && dropped != "" {
                    print("Returned completed delivery: \(name)")
                    return Posting(
                        id: id, item_name: name, item_details: details, item_image: image,
                        item_donor: donor, item_address: address, item_deliverer: deliverer,
                        item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress,
                        item_donEmail: donEmail, item_claimed: claimed, item_picked: picked,
                        item_dropped: dropped, item_quantity: quantity,
                        item_lat: lat, item_long: long,
                        item_expiryDate: expiryDate,
                        item_pickupSelf: pickupSelf,
                        containsPeanuts: containsPeanuts,
                        containsTreeNuts: containsTreeNuts,
                        containsMilk: containsMilk,
                        containsEggs: containsEggs,
                        containsFish: containsFish,
                        containsShellfish: containsShellfish,
                        containsWheat: containsWheat,
                        containsSoy: containsSoy
                    )
                } else {
                    print("Skipped post: \(name) — dropped: \(dropped), deliverer: \(deliverer)")
                    return nil
                }
            }
        }
    }
    
    func fetchDonorPastData(donorEmail: String) {
        print("Fetching COMPLETED donor postings for: \(donorEmail)")
        let db = Firestore.firestore()
        
        db.collection("Postings").getDocuments { (snap, err) in
            guard let itemData = snap else {
                print("No postings snapshot")
                return
            }

            self.donor_Past_Postings = itemData.documents.compactMap { doc in
                let id = doc.documentID
                let name = doc.get("item_name") as? String ?? ""
                let image = doc.get("item_image") as? String ?? ""
                let details = doc.get("item_details") as? String ?? ""
                let donor = doc.get("item_donor") as? String ?? ""
                let address = doc.get("item_address") as? String ?? ""
                let deliverer = doc.get("item_deliverer") as? String ?? ""
                let beneficiary = doc.get("item_beneficiary") as? String ?? ""
                let benEmail = doc.get("item_benEmail") as? String ?? ""
                let benAddress = doc.get("item_benAddress") as? String ?? ""
                let donEmail = doc.get("item_donEmail") as? String ?? ""
                let claimed = doc.get("item_claimed") as? String ?? ""
                let picked = doc.get("item_picked") as? String ?? ""
                let dropped = doc.get("item_dropped") as? String ?? ""
                let quantity = doc.get("item_quantity") as? String ?? ""
                let expiryString = doc.get("item_expiryDate") as? String ?? ""
                let expiryDate = ISO8601DateFormatter().date(from: expiryString) ?? Date.distantPast
                let pickupSelf = doc.get("item_pickupSelf") as? Bool ?? false
                
                // Allergen flags
                let containsPeanuts = doc.get("containsPeanuts") as? Bool ?? false
                let containsTreeNuts = doc.get("containsTreeNuts") as? Bool ?? false
                let containsMilk = doc.get("containsMilk") as? Bool ?? false
                let containsEggs = doc.get("containsEggs") as? Bool ?? false
                let containsFish = doc.get("containsFish") as? Bool ?? false
                let containsShellfish = doc.get("containsShellfish") as? Bool ?? false
                let containsWheat = doc.get("containsWheat") as? Bool ?? false
                let containsSoy = doc.get("containsSoy") as? Bool ?? false
                
                // Flexible lat/long parsing
                let lat: Double
                if let latValue = doc.get("item_lat") {
                    if let number = latValue as? NSNumber {
                        lat = number.doubleValue
                    } else if let string = latValue as? String, let doubleVal = Double(string) {
                        lat = doubleVal
                    } else {
                        lat = 0.0
                    }
                } else {
                    lat = 0.0
                }

                let long: Double
                if let longValue = doc.get("item_long") {
                    if let number = longValue as? NSNumber {
                        long = number.doubleValue
                    } else if let string = longValue as? String, let doubleVal = Double(string) {
                        long = doubleVal
                    } else {
                        long = 0.0
                    }
                } else {
                    long = 0.0
                }
                
                // Only include postings where picked is not empty
                guard donEmail == donorEmail && !picked.isEmpty else {
                    print("Skipped post: \(name) — picked: \(picked), donor: \(donEmail)")
                    return nil
                }
                
                print("Returned completed donor posting: \(name)")
                return Posting(
                    id: id, item_name: name, item_details: details, item_image: image,
                    item_donor: donor, item_address: address, item_deliverer: deliverer,
                    item_beneficiary: beneficiary, item_benEmail: benEmail, item_benAddress: benAddress,
                    item_donEmail: donEmail, item_claimed: claimed, item_picked: picked,
                    item_dropped: dropped, item_quantity: quantity,
                    item_lat: lat, item_long: long,
                    item_expiryDate: expiryDate,
                    item_pickupSelf: pickupSelf,
                    containsPeanuts: containsPeanuts,
                    containsTreeNuts: containsTreeNuts,
                    containsMilk: containsMilk,
                    containsEggs: containsEggs,
                    containsFish: containsFish,
                    containsShellfish: containsShellfish,
                    containsWheat: containsWheat,
                    containsSoy: containsSoy
                )
            }
            
            // Sort locally by expiryDate (newest first)
            self.donor_Past_Postings.sort { $0.item_expiryDate > $1.item_expiryDate }
            
            print("Final donor_Past_Postings count: \(self.donor_Past_Postings.count)")
            print("donor_Past_Postings: \(self.donor_Past_Postings.map { $0.item_name })")
        }
    }

}

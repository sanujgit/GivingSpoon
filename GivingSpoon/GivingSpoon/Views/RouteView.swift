//
//  RouteView.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct RouteView: View {
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    private let startingPoint = CLLocationCoordinate2D(latitude: 40.83657, longitude: 14.30689)
    private let destinationCoordinates = CLLocationCoordinate2D(latitude: 40.849761, longitude: 14.263364)
    
    var body: some View {
        Text("Travel Time: \(travelTime ?? "Loading...")")
        Map(selection: $selectedResult) {
            Marker("start", coordinate: self.startingPoint)
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            Marker("end", coordinate: self.destinationCoordinates)
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onAppear {
            self.selectedResult = MKMapItem(placemark: MKPlacemark(coordinate: self.destinationCoordinates))
        }
    }
    
    func getDirections() {
        self.route = nil
        guard let selectedResult else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.startingPoint))
        request.destination = selectedResult
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    RouteView()
}

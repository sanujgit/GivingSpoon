//
//  BPostingsInfoNew.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct BPostingsInfoNew: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    var body: some View {
        NavigationView {
            VStack {
                // IMAGE OF FOOD ITEM POSTED BY DONOR
                List {
                    // quantity of item
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("quantity")
                    }
                    // which restaurant is this coming from
                    HStack {
                        Text("Restaurant")
                        Spacer()
                        Text("restaurant name")
                    }
                    // which address is this restaurant located
                    HStack {
                        Text("Address")
                        Spacer()
                        Text("address of restaurant")
                    }
                }
                // button called "CLAIM"
                Button {
                    
                } label: {
                    Text("Claim")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .frame(maxWidth: 360, maxHeight: 60)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.top, 20)
            }
            //.navigationTitle(food item name)
            .navigationTitle("Food Item Name")
        }
    }
}

#Preview {
    BPostingsInfoNew()
}

//
//  BMenu.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct BMenu: View {
    @ObservedObject var homeData: BeneficiaryViewModel
    var body: some View {
        VStack {
            Button(action: {}, label: {
                HStack (spacing: 15) {
                    Image(systemName: "cart")
                        .font(.title)
                        .foregroundColor(.pink)
                    Text("Cart")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer(minLength: 0)
                }
                .padding()
            })
            
            Spacer()
            
            HStack {
                Spacer()
                Text("Version 0.1")
                    .fontWeight(.bold)
                    .foregroundColor(.pink)
            }
            .padding(10)
        }
        .padding([.top, .trailing])
        .frame(width: UIScreen.main.bounds.width/1.6)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    BMenu(homeData: BeneficiaryViewModel())
}

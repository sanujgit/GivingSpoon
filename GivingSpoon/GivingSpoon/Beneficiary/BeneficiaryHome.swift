//
//  BeneficiaryHome.swift
//  GivingSpoon
//
//  Created by Sharika Anuj on 8/15/25.
//

import SwiftUI

struct BeneficiaryHome: View {
    @StateObject var bHomeModel = BeneficiaryViewModel()
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    Button(action: {
                        withAnimation(.easeIn) {
                            bHomeModel.showMenu.toggle()
                        }
                    }, label: {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.pink)
                    })
                    Text(bHomeModel.userLocation == nil ? "Locating..." : "Deliver to: ")
                        .foregroundColor(.black)
                    Text(bHomeModel.userAddress2)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.pink)
                    Spacer(minLength: 0)
                }.padding([.horizontal, .top])
                
                Divider()
                
                HStack(spacing: 15) {
                    TextField("Search", text: $bHomeModel.search)
                    if bHomeModel.search != "" {
                        Button(action: {
                            withAnimation(.easeIn) {
                                
                            }
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.gray)
                        })
                    }
                }.padding(.horizontal).padding(.top, 10)
                
                Spacer()
            }
            
            HStack {
                BMenu(homeData: bHomeModel)
                    .offset(x: bHomeModel.showMenu ? 0: -UIScreen.main.bounds.width/1.6)
                Spacer(minLength: 0)
            }
            .background(Color.black.opacity(bHomeModel.showMenu ? 0.3: 0).ignoresSafeArea().onTapGesture(perform: {
                withAnimation(.easeIn) {
                    bHomeModel.showMenu.toggle()
                }
            }))
            
            
            if bHomeModel.noLocation {
                Text("Please enable location access.")
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 100, height: 120)
                    .background(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3).ignoresSafeArea())
            }
        }
        .onAppear(perform: {
            bHomeModel.locationManager.delegate = bHomeModel
            //bHomeModel.locationManager.requestWhenInUseAuthorization()
        })
    }
}

#Preview {
    BeneficiaryHome()
}

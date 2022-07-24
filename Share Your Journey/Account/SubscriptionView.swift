//
//  SubscriptionView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/07/2022.
//

import SwiftUI
import StoreKit
import RevenueCat

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var subscriber: Bool
    @State private var availablePackages: [Package] = []
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Unlock all app's functions")) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .frame(width: 20)
                        Text("Get walking directions to any part of the journey")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .frame(width: 20)
                        Text("Be able to save any photo to camera roll")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.down.on.square")
                            .frame(width: 20)
                        Text("Be able to save all photos to camera roll at once")
                    }
                    
                    HStack {
                        Image(systemName: "platter.filled.bottom.and.arrow.down.iphone")
                            .frame(width: 20)
                        Text("Be able to save any journey to your own device")
                    }
                }
                
                Section(header: Text("Free trial")) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .frame(width: 20)
                        Text("The first week is free. You can cancel subscription at any time.")
                    }
         
                }
                ForEach(availablePackages, id: \.self.storeProduct) { package in
                    let timeUnit = String(String(package.id).suffix(String(package.id).count - 4))
                    Section(header: Text("\(timeUnit) subscription")) {
                        Button("Buy for \(package.localizedPriceString)") {
                            
                            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                                if customerInfo?.entitlements["allfeatures"]?.isActive == true {
                                  subscriber = true
                                  dismiss()
                              }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                    }
                }
              }
            .task {
                Purchases.shared.getOfferings { (offerings, error) in
                    if let packages = offerings?.offering(identifier: "default")?.availablePackages {
                        availablePackages = packages
                    }
                }
            }
            .navigationTitle("Premium Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Later"){
                        dismiss()
                    }
                }
            }
        }
    }
}

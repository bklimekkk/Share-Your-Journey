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
                Section(header: Text(UIStrings.unlockAllFunctions)) {
                    HStack {
                        Image(systemName: Icons.figureWalk)
                            .frame(width: 20)
                        Text(UIStrings.getWalkingDirections)
                    }
                    
                    HStack {
                        Image(systemName: Icons.squareAndArrowDown)
                            .frame(width: 20)
                        Text(UIStrings.beAbleToSaveAnyPhoto)
                    }
                    
                    HStack {
                        Image(systemName: Icons.squareAndArrowDownOnSquare)
                            .frame(width: 20)
                        Text(UIStrings.beAbleToSaveAllPhotos)
                    }
                    
                    HStack {
                        Image(systemName: Icons.platterFilledBottomAndArrowDownIphone)
                            .frame(width: 20)
                        Text(UIStrings.beAbleToSaveAnyJourney)
                    }
                }
                
                Section(header: Text(UIStrings.freeTrial)) {
                    HStack {
                        Image(systemName: Icons.dollarsignCircleFill)
                            .frame(width: 20)
                        Text(UIStrings.firstWeekIsFree)
                    }
                    
                }
                ForEach(self.availablePackages, id: \.self.storeProduct) { package in
                    let timeUnit = String(String(package.id).suffix(String(package.id).count - 4))
                    Section(header: Text("\(timeUnit) subscription")) {
                        Button("Buy for \(package.localizedPriceString)") {
                            
                            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                                if customerInfo?.entitlements[Links.allFeaturesEntitlement]?.isActive == true {
                                    self.dismiss()
                                    self.subscriber = true
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
                    if let packages = offerings?.offering(identifier: Links.defaultOffering)?.availablePackages {
                        self.availablePackages = packages
                    }
                }
            }
            .navigationTitle(UIStrings.premiumAccess)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(UIStrings.done){
                        self.dismiss()
                    }
                }
            }
        }
    }
}

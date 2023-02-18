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
    @State private var tappedBuyForButton = false
    @State private var choice = ""
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
                        Button {
                            tappedBuyForButton = true
                            choice = package.localizedPriceString
                            Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                                if error != nil {
                                    tappedBuyForButton = false
                                }
                                if customerInfo?.entitlements[Links.allFeaturesEntitlement]?.isActive == true {
                                    self.dismiss()
                                    self.subscriber = true
                                }
                            }
                        } label: {
                            if self.tappedBuyForButton && self.choice == package.localizedPriceString {
                                ProgressView()
                            } else {
                                Text("Buy for \(package.localizedPriceString)")
                            }
                        }
                        .disabled(self.tappedBuyForButton && self.choice == package.localizedPriceString)
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

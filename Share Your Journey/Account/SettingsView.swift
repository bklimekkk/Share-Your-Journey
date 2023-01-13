//
//  SettingsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/07/2022.
//

import SwiftUI
import RevenueCat

struct SettingsView: View {
    @StateObject var subscription = Subscription()
    @Environment(\.dismiss) var dismiss
    @Binding var loggedOut: Bool
    @State private var askAboutAccountDeletion = false
    @State private var showPrivacyPolicy = false
    @State private var showInstructions = false
    @State private var deletedAccount = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("shareyourjourneyhelp@gmail.com") {}
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                    Button(UIStrings.instructions) {
                        self.showInstructions = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    Button(UIStrings.privacyPolicy) {
                        self.showPrivacyPolicy = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                
                if !self.subscription.subscriber {
                    Section(header: Text(UIStrings.premiumAccess)) {
                        Button(UIStrings.premiumAccess) {
                            self.subscription.showPanel = true
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(self.subscription.subscriber ? .red : .blue)
                        Button(UIStrings.restorePremiumAccess) {
                            Purchases.shared.restorePurchases { customerInfo, error in
                                if customerInfo?.entitlements[Links.allFeaturesEntitlement]?.isActive == true {
                                    withAnimation {
                                        self.subscription.subscriber = true
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(self.subscription.subscriber ? .red : .blue)
                    }
                }
                Section(header: Text(UIStrings.accountDeletion)) {
                    Button(UIStrings.deleteYourAccount){
                        self.askAboutAccountDeletion = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
            .task {
                Purchases.shared.getCustomerInfo { (customerInfo, error) in
                    if customerInfo!.entitlements[Links.allFeaturesEntitlement]?.isActive == true {
                        self.subscription.subscriber = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showInstructions, content: {
                InstructionsView()
            })
            .fullScreenCover(isPresented: self.$subscription.showPanel,
                             content: {
                SubscriptionView(subscriber: self.$subscription.subscriber)
            })
            .sheet(isPresented: self.$showPrivacyPolicy,
                   content: {
                WebView(url: URL(string: Links.privacyPolicyPage)!)
            })
            .navigationTitle(self.subscription.subscriber ? UIStrings.premiumAccount : UIStrings.regularAccount)
            .navigationBarTitleDisplayMode(.inline)
            .alert(UIStrings.accountDeleted, isPresented: self.$deletedAccount, actions: {
                Button(UIStrings.ok, role: .cancel){
                    self.loggedOut = true
                    self.dismiss()
                }
            }, message: {
                Text(UIStrings.accountDeletedInformation)
            })
            .alert(UIStrings.accountDeletion, isPresented: self.$askAboutAccountDeletion) {
                Button(UIStrings.deleteAccount, role: .destructive) {
                    let email = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString
                    FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.myJourneys(email: email)).getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            for i in querySnapshot!.documents {
                                let photosNumber = i.get("photosNumber") as? Int ?? IntConstants.defaultValue
                                for j in 0...photosNumber - 1 {
                                    let deleteReference = FirebaseSetup.firebaseInstance.storage.reference().child("\(email)/\(i.documentID)/\(j)")
                                    deleteReference.delete { error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    FirebaseSetup.firebaseInstance.auth.currentUser?.delete()
                    FirebaseSetup.firebaseInstance.db.collection("users").document(email).updateData(["deletedAccount" : true]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                    FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getFriends(email: email)).getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            for i in querySnapshot!.documents {
                                if i.documentID != email {
                                    let accountReference = FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getFriends(email: i.documentID)).document(email)
                                    accountReference.updateData(["deletedAccount" : true])
                                    FirebaseSetup.firebaseInstance.db.collection("\(FirestorePaths.getFriends(email: email))/\(i.documentID)/journeys").getDocuments { querySnapshot, error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        } else {
                                            for j in querySnapshot!.documents {
                                                if j.documentID != "-" {
                                                    FirebaseSetup.firebaseInstance.db.collection("\(FirestorePaths.getFriends(email: email))/\(i.documentID)/journeys").document(j.documentID).updateData(["deletedJourney" : true])
                                                    //                                                    deleteAllPhotos(path: "users/\(email)/friends/\(i.documentID)/journeys", journeyToDelete: j.documentID)
                                                    //                                                    deleteJourneyFromServer(path: "users/\(email)/friends/\(i.documentID)/journeys", journeyToDelete: j.documentID)
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                
                                FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.myJourneys(email: email)).getDocuments { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        for i in querySnapshot!.documents {
                                            if i.documentID != "-" {
                                                FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.myJourneys(email: email)).document(i.documentID).updateData(["deletedJourney" : true])
                                                //                                                deleteAllPhotos(path: "users/\(email)/friends/\(email)/journeys", journeyToDelete: i.documentID)
                                                //                                                deleteJourneyFromServer(path: "users/\(email)/friends/\(email)/journeys", journeyToDelete: i.documentID)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.deletedAccount = true
                }
            } message: {
                Text(UIStrings.accountDeletionChecker)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.dismiss()
                    }label: {
                        SheetDismissButtonView()
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for deleting all images' references from firestore database.
     */
    func deleteAllPhotos(path: String, journeyToDelete: String) {
        FirebaseSetup.firebaseInstance.db.collection("\(path)/\(journeyToDelete)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    i.reference.delete()
                }
            }
        }
    }
    
    /**
     Function is responsible for deleting journey collection from firestore database.
     */
    func deleteJourneyFromServer(path: String, journeyToDelete: String) {
        FirebaseSetup.firebaseInstance.db.collection(path).document(journeyToDelete).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(UIStrings.journeyDeletedSuccesfully)
            }
        }
    }
}

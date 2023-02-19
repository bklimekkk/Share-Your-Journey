//
//  SettingsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/07/2022.
//

import SwiftUI
import Firebase
import RevenueCat

struct SettingsView: View {
    @StateObject var subscription = Subscription()
    @Environment(\.dismiss) var dismiss
    @Binding var loggedOut: Bool
    @State private var askAboutAccountDeletion = false
    @State private var showPrivacyPolicy = false
    @State private var showInstructions = false
    @State private var deletedAccount = false
    @State private var changeNickname = false
    @State private var nickname = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hello \(self.nickname)!")) {
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
                Section(header: Text(UIStrings.accountSettings)) {
                    Button(UIStrings.changeNickname) {
                        self.changeNickname = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
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

                self.nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""

            }
            .fullScreenCover(isPresented: $showInstructions, content: {
                InstructionsView()
            })
            .fullScreenCover(isPresented: self.$subscription.showPanel,
                             content: {
                SubscriptionView(subscriber: self.$subscription.subscriber)
            })
            .sheet(isPresented: self.$changeNickname, onDismiss: {
                self.nickname = UserDefaults.standard.value(forKey: "nickname") as? String ?? ""
            }, content: {
                ChangeNicknameView(oldNickname: self.nickname)
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
            .alert(UIStrings.accountSettings, isPresented: self.$askAboutAccountDeletion) {
                Button(UIStrings.deleteAccount, role: .destructive) {
                    let uid = Auth.auth().currentUser?.uid ?? ""
                    Firestore.firestore().collection(FirestorePaths.myJourneys(uid: uid)).getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            for journey in querySnapshot!.documents {
                                let photosNumber = journey.get("photosNumber") as? Int ?? IntConstants.defaultValue
                                for photoNumber in 0...photosNumber - 1 {
                                    let deleteReference = Storage.storage().reference().child("\(uid)/\(journey.documentID)/\(photoNumber)")
                                    deleteReference.delete { error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Auth.auth().currentUser?.delete()
                    Firestore.firestore().collection("users").document(uid).updateData(["deletedAccount" : true]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                    
                    Firestore.firestore().collection(FirestorePaths.getFriends(uid: uid)).getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let documents = querySnapshot!.documents.filter({$0.documentID != uid})
                            for friend in documents {
                                let accountReference = Firestore.firestore().collection(FirestorePaths.getFriends(uid: friend.documentID)).document(uid)
                                accountReference.updateData(["deletedAccount" : true])
                                Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: uid))/\(friend.documentID)/journeys").getDocuments { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        for journey in querySnapshot!.documents {
                                            Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: uid))/\(friend.documentID)/journeys").document(journey.documentID).updateData(["deletedJourney" : true])
                                            //                                                    deleteAllPhotos(path: "users/\(uid)/friends/\(friend.documentID)/journeys", journeyToDelete: journey.documentID)
                                            //                                                    deleteJourneyFromServer(path: "users/\(uid)/friends/\(friend.documentID)/journeys", journeyToDelete: journey.documentID)
                                        }
                                    }
                                }
                                
                                Firestore.firestore().collection(FirestorePaths.myJourneys(uid: uid)).getDocuments { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        for journey in querySnapshot!.documents {
                                            Firestore.firestore().collection(FirestorePaths.myJourneys(uid: uid)).document(journey.documentID).updateData(["deletedJourney" : true])
                                            //                                                deleteAllPhotos(path: "users/\(uid)/friends/\(uid)/journeys", journeyToDelete: friend.documentID)
                                            //                                                deleteJourneyFromServer(path: "users/\(uid)/friends/\(uid)/journeys", journeyToDelete: friend.documentID)
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
        Firestore.firestore().collection("\(path)/\(journeyToDelete)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for photo in querySnapshot!.documents {
                    photo.reference.delete()
                }
            }
        }
    }
    
    /**
     Function is responsible for deleting journey collection from firestore database.
     */
    func deleteJourneyFromServer(path: String, journeyToDelete: String) {
        Firestore.firestore().collection(path).document(journeyToDelete).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(UIStrings.journeyDeletedSuccesfully)
            }
        }
    }
}

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
                    Button("Instructions") {
                        self.showInstructions = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    Button("Privacy Policy") {
                        self.showPrivacyPolicy = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                
                if !self.subscription.subscriber {
                    Section(header: Text("premium access")) {
                        Button("Premium Access") {
                            self.subscription.showPanel = true
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(self.subscription.subscriber ? .red : .blue)
                        Button("Restore Your Premium Access") {
                            Purchases.shared.restorePurchases { customerInfo, error in
                                if customerInfo?.entitlements["allfeatures"]?.isActive == true {
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
                
                Section(header: Text("account deletion")) {
                    Button("Delete Your Account"){
                        self.askAboutAccountDeletion = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
            .task {
                Purchases.shared.getCustomerInfo { (customerInfo, error) in
                    if customerInfo!.entitlements["allfeatures"]?.isActive == true {
                        self.subscription.subscriber = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showInstructions, content: {
                InstructionsView()
            })
            .fullScreenCover(isPresented: self.$subscription.showPanel, content: {
                SubscriptionView(subscriber: self.$subscription.subscriber)
            })
            .sheet(isPresented: self.$showPrivacyPolicy, content: {
                WebView(url: URL(string: "https://bklimekkk.github.io/share-your-journey-privacy-policy/")!)
            })
            .navigationTitle(self.subscription.subscriber ? "Premium Account" : "Regular Account")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Account deleted", isPresented: self.$deletedAccount, actions: {
                Button("Ok", role: .cancel){
                    self.loggedOut = true
                    self.dismiss()
                }
            }, message: {
                Text("Your account has been deleted")
            })
            .alert("Account deletion", isPresented: self.$askAboutAccountDeletion) {
                Button("Delete account", role: .destructive) {
                    let email = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
                    
                    
                    FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(email)/journeys").getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            for i in querySnapshot!.documents {
                                let photosNumber = i.get("photosNumber") as! Int
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
                    
                    FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends").getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            for i in querySnapshot!.documents {
                                if i.documentID != email {
                                    let accountReference = FirebaseSetup.firebaseInstance.db.collection("users/\(i.documentID)/friends").document(email)
                                    
                                    accountReference.updateData(["deletedAccount" : true])
                                    
                                    FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(i.documentID)/journeys").getDocuments { querySnapshot, error in
                                        if let error = error {
                                            print(error.localizedDescription)
                                        } else {
                                            for j in querySnapshot!.documents {
                                                if j.documentID != "-" {
                                                    
                                                    FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(i.documentID)/journeys").document(j.documentID).updateData(["deletedJourney" : true])
                                                    //                                                    deleteAllPhotos(path: "users/\(email)/friends/\(i.documentID)/journeys", journeyToDelete: j.documentID)
                                                    //                                                    deleteJourneyFromServer(path: "users/\(email)/friends/\(i.documentID)/journeys", journeyToDelete: j.documentID)
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                
                                FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(email)/journeys").getDocuments { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        for i in querySnapshot!.documents {
                                            if i.documentID != "-" {
                                                FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(email)/journeys").document(i.documentID).updateData(["deletedJourney" : true])
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
                Text("Are you sure that you want to delete your account? You won't be able to create account using the same e-mail address.")
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
                print("journey deleted successfully")
            }
        }
    }
}

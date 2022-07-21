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
                       showInstructions = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    Button("Privacy Policy") {
                        showPrivacyPolicy = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    Button(subscription.subscriber ? "Quit Premium Access" : "Premium Access") {
                        subscription.showPanel = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(subscription.subscriber ? .red : .blue)
                }
                
                Section {
                    Button("Delete Account"){
                        askAboutAccountDeletion = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
            .task {
                Purchases.shared.getCustomerInfo { (customerInfo, error) in
                    if customerInfo!.entitlements["allfeatures"]?.isActive == true {
                        subscription.subscriber = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showInstructions, content: {
                InstructionsView()
            })
            .fullScreenCover(isPresented: $subscription.showPanel, content: {
                SubscriptionView(subscriber: $subscription.subscriber)
            })
            .sheet(isPresented: $showPrivacyPolicy, content: {
                WebView(url: URL(string: "https://bklimekkk.github.io/share-your-journey-privacy-policy/")!)
            })
            .navigationTitle(subscription.subscriber ? "Premium Account" : "Regular Account")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Account deleted", isPresented: $deletedAccount, actions: {
                Button("Ok", role: .cancel){
                    loggedOut = true
                    dismiss()
                }
            }, message: {
                Text("Your account has been deleted")
            })
            .alert("Account deletion", isPresented: $askAboutAccountDeletion) {
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
                                                    
                                                    
                                                    
                                                    
                                                    
//
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
                    deletedAccount = true
                }
            } message: {
                Text("Are you sure that you want to delete your account? You won't be able to create account using the same e-mail address.")
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Back to app") {
                        dismiss()
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

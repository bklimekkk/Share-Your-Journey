//
//  SettingsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/07/2022.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var askAboutAccountDeletion = false
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("shareyourjourneyhelp@gmail.com") {}
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                    Button("Instructions") {
                        
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                    Button("Privacy Policy") {
                        showPrivacyPolicy = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                
                Section {
                    Button("Delete Account"){
                        askAboutAccountDeletion = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showPrivacyPolicy, content: {
                WebView(url: URL(string: "https://bklimekkk.github.io/share-your-journey-privacy-policy/")!)
            })
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
                }
            } message: {
                Text("Are you sure that you want to delete your account?")
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

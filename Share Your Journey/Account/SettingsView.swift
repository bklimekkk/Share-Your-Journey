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

    var uid: String {
        Auth.auth().currentUser?.uid ?? ""
    }

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
                    self.clearStorage {
                        self.deleteAllReceivedPhotos {
                            self.deleteAllReceivedJourneys {
                                self.deleteFromAllFriendsLists {
                                    self.deleteAllPhotos {
                                        self.deleteAllJourneys {
                                            self.deleteAllFriends {
                                                self.deleteUser {
                                                    self.deleteAuth {
                                                        self.loggedOut = true
                                                        self.dismiss()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } message: {
                Text(UIStrings.accountDeletionChecker)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.dismiss()
                    } label: {
                        SheetDismissButtonView()
                    }
                }
            }
        }
    }

    func deleteJourneyFromStorage(name: String, numberOfPhotos: Int, completion: @escaping () -> Void) {
        let photosToDelete = numberOfPhotos
        var deletedPhotos = 0
        for photoNumber in 0...numberOfPhotos {
            let deleteReference = Storage.storage().reference().child("\(Auth.auth().currentUser?.uid ?? "")/\(name)/\(photoNumber)")
            deleteReference.delete { error in
                if error != nil {
                    print("Error while deleting journey from storage")
                    completion()
                } else {
                    print("Photo deleted from storage successfully")
                    deletedPhotos += 1
                    if deletedPhotos == photosToDelete {
                        completion()
                    }
                }
            }
        }
    }

    func clearStorage(completion: @escaping () -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends/\(self.uid)/journeys").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let journeys = snapshot?.documents {
                    if journeys.isEmpty {
                        completion()
                    }
                let journeysToDelete = journeys.count
                var deletedJourneys = 0
                journeys.forEach { journey in
                    let journeyName = journey.documentID
                    let numberOfPhotos = journey.get("photosNumber") as? Int
                    if let numberOfPhotos = numberOfPhotos {
                        self.deleteJourneyFromStorage(name: journeyName, numberOfPhotos: numberOfPhotos) {
                            deletedJourneys += 1
                            if deletedJourneys == journeysToDelete {
                                completion()
                            }
                        }
                    }
                }
                } else {
                    completion()
                }
            }
        }
    }

    // TODO: - this should be first function called while deleting the account.
    func deleteAllReceivedPhotos(completion: @escaping () -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let friends = snapshot?.documents {
                    if friends.isEmpty {
                        completion()
                    }
                    var referencesToDelete = 0
                    var deletedReferences = 0
                    friends.forEach { friend in
                        Firestore.firestore().collection("users/\(friend.documentID)/friends/\(self.uid)/journeys").getDocuments { snapshot, error in
                            if error != nil {
                                print(error?.localizedDescription)
                                completion()
                            } else {
                                if let journeys = snapshot?.documents {
                                    if journeys.isEmpty {
                                        completion()
                                    }
                                    journeys.forEach { journey in
                                        Firestore.firestore().collection("users/\(friend.documentID)/friends/\(self.uid)/journeys/\(journey.documentID)/photos").getDocuments { snapshot, error in
                                            if error != nil {
                                                print(error?.localizedDescription)
                                                completion()
                                            } else {
                                                if let photos = snapshot?.documents {
                                                    if photos.isEmpty {
                                                        completion()
                                                    }
                                                    referencesToDelete += photos.count
                                                    photos.forEach { photo in
                                                        photo.reference.delete { error in
                                                            if error != nil {
                                                                print(error?.localizedDescription)
                                                                completion()
                                                            } else {
                                                                deletedReferences += 1
                                                                if referencesToDelete == deletedReferences {
                                                                    completion()
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    completion()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func deleteAllReceivedJourneys(completion: @escaping () -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let friends = snapshot?.documents {
                    if friends.isEmpty {
                        completion()
                    }
                    var referencesToDelete = 0
                    var deletedReferences = 0
                    friends.forEach { friend in
                        Firestore.firestore().collection("users/\(friend.documentID)/friends/\(self.uid)/journeys").getDocuments { snapshot, error in
                            if error != nil {
                                print(error?.localizedDescription)
                                completion()
                            } else {
                                if let journeys = snapshot?.documents {
                                    if journeys.isEmpty {
                                        completion()
                                    }
                                    referencesToDelete += journeys.count
                                    journeys.forEach { journey in
                                        journey.reference.delete { error in
                                            if error != nil {
                                                print(error?.localizedDescription)
                                                completion()
                                            } else {
                                                deletedReferences += 1
                                                if referencesToDelete == deletedReferences {
                                                    completion()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func deleteFromAllFriendsLists(completion: @escaping () -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let friends = snapshot?.documents {
                    if friends.isEmpty {
                        completion()
                    }
                    let referencesToDelete = friends.count
                    var deletedReferences = 0
                    friends.forEach { friend in
                        Firestore.firestore().collection("users/\(friend.documentID)/friends").getDocuments { snapshot, error in
                            if error != nil {
                                print(error?.localizedDescription)
                                completion()
                            } else {
                                if let myDocument = snapshot?.documents.first(where: ({$0.documentID == self.uid})) {
                                    myDocument.reference.delete { error in
                                        if error != nil {
                                            print(error?.localizedDescription)
                                            completion()
                                        } else {
                                            deletedReferences += 1
                                            if referencesToDelete == deletedReferences {
                                                completion()
                                            }
                                        }
                                    }
                                } else {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func deleteAllPhotos(completion: @escaping() -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let friends = snapshot?.documents {
                    if friends.isEmpty {
                        completion()
                    }
                    var referencesToDelete = 0
                    var deletedReferences = 0
                    friends.forEach { friend in
                        Firestore.firestore().collection("users/\(self.uid)/friends/\(friend.documentID)/journeys").getDocuments { snapshot, error in
                            if error != nil {
                                print(error?.localizedDescription)
                                completion()
                            } else {
                                if let journeys = snapshot?.documents {
                                    if journeys.isEmpty {
                                        completion()
                                    }
                                    journeys.forEach { journey in
                                        Firestore.firestore().collection("users/\(self.uid)/friends/\(friend.documentID)/journeys/\(journey.documentID)/photos").getDocuments { snapshot, error in
                                            if error != nil {
                                                print(error?.localizedDescription)
                                                completion()
                                            } else {
                                                if let photos = snapshot?.documents {
                                                    if photos.isEmpty {
                                                        completion()
                                                    }
                                                    referencesToDelete += photos.count
                                                    photos.forEach { photo in
                                                        photo.reference.delete { error in
                                                            if error != nil {
                                                                print(error?.localizedDescription)
                                                                completion()
                                                            } else {
                                                                deletedReferences += 1
                                                                if deletedReferences == referencesToDelete {
                                                                    completion()
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    completion()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func deleteAllJourneys(completion: @escaping() -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let friends = snapshot?.documents {
                    if friends.isEmpty {
                        completion()
                    }
                    var referencesToDelete = 0
                    var deletedReferences = 0
                    friends.forEach { friend in
                        Firestore.firestore().collection("users/\(self.uid)/friends/\(friend.documentID)/journeys").getDocuments { snapshot, error in
                            if error != nil {
                                print(error?.localizedDescription)
                                completion()
                            } else {
                                if let journeys = snapshot?.documents {
                                    if journeys.isEmpty {
                                        completion()
                                    }
                                    referencesToDelete += journeys.count
                                    journeys.forEach { journey in
                                        journey.reference.delete { error in
                                            if error != nil {
                                                print(error?.localizedDescription)
                                                completion()
                                            } else {
                                                deletedReferences += 1
                                                if deletedReferences == referencesToDelete {
                                                    completion()
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func deleteAllFriends(completion: @escaping() -> Void) {
        Firestore.firestore().collection("users/\(self.uid)/friends").getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                if let friends = snapshot?.documents {
                    if friends.isEmpty {
                        completion()
                    }
                    let referencesToDelete = friends.count
                    var deletedReferences = 0
                    friends.forEach { friend in
                        friend.reference.delete { error in
                            if error != nil {
                                print(error?.localizedDescription)
                                completion()
                            } else {
                                deletedReferences += 1
                                if deletedReferences == referencesToDelete {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }

    func deleteUser(completion: @escaping () -> Void) {
        Firestore.firestore().collection("users").document(self.uid).delete { error in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                completion()
            }
        }
    }

    func deleteAuth(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        user.delete { error in
            if let error = error {
                print(error.localizedDescription)
                completion()
            } else {
                print("User account deleted successfully.")
                completion()
            }
        }
    }
}

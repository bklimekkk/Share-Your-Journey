//
//  UIStrings.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 01/01/2023.
//

import Foundation

struct UIStrings {
    //general
    //journey
    static let emptyString = ""
    static let tryAgain = "TryAgain"
    static let myLocationString = "My Location"
    static let saveAllImagesToCameraRoll = "Save all images to camera roll"
    static let quitButtonTitle = "Quit"
    static let saveJourneyButtonTitle = "Save journey"
    static let yourJourneyTabTitle = "Your Journey"
    static let journeysTabTitle = "Journeys"
    static let friendsTabTitle = "Friends"
    static let firstWelcomeText = "1. Create your account / Log in to existing one."
    static let secondWelcomeText = "2. Start the journey, travel wherever you want and take pictures."
    static let thirdWelcomeText = "3. Finish and save the journey"
    static let fourthWelcomeText = "4. Invite friends using their e-mails."
    static let fifthWelcomeText = "5. Send any previously saved journey to your friend."
    static let sixthWelcomeText = "6. See where your firends went by viewing pictures they took on the map."
    static let seventhWelcomeText = "7. Enjoy!"
    static let startUsingTheApp = "Start using the app"
    static let welcome = "Welcome to Share Your Journey app"
    static let login = "Login"
    static let createAccount = "Create Account"
    static let emailAddress = "E-mail address"
    static let password = "Passowrd"
    static let repeatPassword = "Repeat password"
    static let forgotMyPassword = "Forgot my password"
    static let ok = "Ok"
    static let emailKey = "email"
    static let passwordKey = "password"
    static let passwordResetEmail = "Password reset e-mail"
    static let accountNotYetVerified = "Account hasn't been verified yet"
    static let verifyAgain = "Verify again"
    static let verificationError = "Verification error"
    static let resetPasswordEmailSent = "Reset password e-mail was sent to"
    static let passwordFieldsNotMatching = "Password fields don't match"
    static let sendingVerificationError = "There was an error while sending verification"
    static let proceedToApp = "Proceed to app"
    static let verificationEmail = "Verification e-mail"
    static let verificationEmailSent = "A verification e-mail has been sent to"
    static let verifyYourself = ", verify yourself to be able to log in. If you don't find the e-mail, make sure you check the spam."
    static let enterEmailToReset = "Enter your email address to reset the password"
    static let yourEmail = "Your e-mail address"
    static let resetPasswordEmailError = "There was an error while sending reset password email"
    static let resetPassword = "Reset password"
    static let emailFieldIsEmpty = "Email field is empty"
    static let instructions = "Instructions"
    static let privacyPolicy = "Privacy Policy"
    static let premiumAccess = "Premium Access"
    static let restorePremiumAccess = "Restore Your Premium Access"
    static let accountDeletion = "Account Deletion"
    static let deleteYourAccount = "Delete Your Account"
    static let premiumAccount = "Premium Account"
    static let regularAccount = "Regular Account"
    static let accountDeleted = "Account Deleted"
    static let accountDeletedInformation = "Your account has been deleted"
    static let deleteAccount = "Delete Account"
    static let accountDeletionChecker = "Are you sure that you want to delete your account? You won't be able to create account using the same e-mail address."
    static let unlockAllFunctions = "Unlock all app's functions"
    static let getWalkingDirections = "Get walking directions to any part of the journey"
    static let beAbleToSaveAnyJourney = "Be able to save any journey to your own device"
    static let freeTrial = "Free trial"
    static let firstWeekIsFree = "The first week is free. You can cancel subscription at any time."
    static let journeyDeletedSuccesfully = "Journey deleted successfully"
    static let done = "Done"
    static let friends = "Friends"
    static let requests = "Requests"
    static let searchEmailAddress = "Search e-mail address"
    static let addANewFriend = "Add a new friend"
    static let noRequestsToShow = "No requests to show. Tap to refresh."
    static let noFriendsToShow = "No friends to show. Tap to refresh."
    static let sentByFriend = "Sent by friend"
    static let sentByYou = "Sent by you"
    static let searchJourney = "Search Journey"
    static let sendJourney = "Send journey"
    static let noJourneysToShow = "No journeys to show. Tap to refresh."
    static let deleteJourney = "Delete Journey"
    static let sureToDelete = "Are you sure that you want to delete this journey?"
    static let cancel = "Cancel"
    static let delete = "Delete"
    static let addAFriend = "Add a friend"
    static let enterFriendsEmail = "Enter friend's e-mail"
    static let inviteFriend = "Invite friend"
    static let invitationError = "Invitation error"
    static let sendRequest = "Send request"
    //invitation errors
    static let mustProvideEmailAddress = "You must provide email address"
    static let yourEmailAddress = "This is your email address"
    static let alreadySentYouRequest = "This friend already sent you a friend request"
    static let alreadyInvitedThisPerson = "You already invited this person"
    static let alreadyFriends = "You are already friends!"
    static let accountDoesntExist = "Account doesn't exist"
    static let quit = "Quit"
    static let invite = "Invite"
    static let searchYourJourneys = "Search your journeys"
    static let noJourneysToSend = "No journeys to send. Tap to refresh."
    static let send = "Send"
    static let finishJourney = "Finish Journey"
    static let areYouSureToFinish = "Are you sure that you want to finish the journey?"
    static let areYouSureToDelete = "Are you sure that you want to delete this yourney?"
    static let yes = "Yes"
    static let shouldContainOnePhoto = "Journey should contain at least one photo"
    static let startJourney = "Start Journey"
    static let currentJourneyImages = "Current Journey Images"
    static let viewingSettingOptions = "Viewing settings options."
    static let resumingTheJourney = "Resuming the journey that was paused."
    static let finishingTheJourney = "Finishing the journey."
    static let deletingTheJourney = "Deleting the journey."
    static let switchingMapTypes = "Switching map types."
    static let recenteringTheMap = "Re-centering the map on user's location."
    static let viewingTakenPhotos = "Viewing photos that have already been taken."
    static let switchingToWalking = "Switching directions options to walking directions."
    static let switchingToDriving = "Switching directions options to driving directions."
    static let loggingOut = "Logging out from the their account."
    static let uploadingImage = "Uploading image from user's camera roll."
    static let takingAPicture = "Taking a picture during the journey."
    static let allowsToPause = "Allows to pause the journey."
    static let downloadingToDevice = "Downloading the journey to device."
    static let allowsToMoveDownloaded = "Allows users to move downloaded journey to the list of saved journeys."
    static let album = "Album"
    static let map = "Map"
    static let downloadAllImages = "Download all images"
    static let download = "Download"
    static let areYouSureToDownload = "Are you sure that you want to download all images to your gallery?"
    static let sendToFriend = "Send To Friend"
    static let areYouSureToQuit = "Are you sure that you want to quit? The journey will be deleted."
    static let sumUp = "Sum up"
    static let continueJourney = "Continue Journey"
    static let location = "Location"
    static let subLocation = "Sublocation"
    static let administrativeArea = "Administrative Area"
    static let country = "Country"
    static let countryCode = "Country Code"
    static let name = "Name"
    static let postalCode = "Postal Code"
    static let ocean = "Ocean"
    static let inlandWater = "Inland Water"
    static let areasOfInterest = "AreasOfInterest"
    static let details = "Details"
    static let chooseRecipients = "Choose recipients"
    static let duplicateJourney = "Duplicate journey"
    static let journeyAlreadyExists = "This journey already exists in your conversation with this person."
    static let repeatTheJourney = "Repeat The Journey"
    static let areYouSureToDownloadAllImages = "Are you sure that you want to download all images to your gallery?"
    static let unableToShowTheJourney = "Unable to show the journey"
    static let sendJourneyInTheApp = "Send journey in the app"
    static let sendPhotosViaSocialMedia = "Send photos via social media"
    static let journeyWithTheSameName = "Journey with the same name"
    static let journeyWithTheSameNameAlreadyDownloaded = "Journey with the same name is already downloaded. Do you want to provide different name to this journey?"
    static let changeName = "Change name"
    static let enterNewName = "Enter new name"
    static let emptyField = "Empty field"
    static let youNeedToProvideAName = "You need to provide a name"
    static let saved = "Saved"
    static let downloaded = "Downloaded"
    static let current = "current"
    static let forecast = "forecast"
    static let date = "Date"
    static let time = "Time"
    static let noPhotos = "No photos"
    static let apple = "Apple"
    static let google = "Google"
}

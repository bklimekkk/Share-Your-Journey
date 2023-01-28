//
//  Enums.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 19/01/2023.
//

import Foundation

//Enum's cases control how users view journey's photos at the particular moment.
enum ViewType {
    case photoAlbum
    case threeDimensional
}

//Enum contains all cases in which users can end up while inviting new friend.
enum InvitationError: String {
    case valid = "Invite friend"
    case yourNickname = "This is your nickname"
    case requestFromFriend = "This friend already sent you a friend request"
    case emptyField = "You must provide nickname"
    case alreadyInvited = "You already invited this person"
    case friendsAlready = "You are already friends!"
    case noAccount = "Account doesn't exist"
}

enum NotificationType {
    case none
    case invitation
    case journey
}

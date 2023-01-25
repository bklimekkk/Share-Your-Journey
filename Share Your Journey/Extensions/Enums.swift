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
enum InvitationError {
    case valid
    case yourNickname
    case requestFromFriend
    case emptyField
    case alreadyInvited
    case friendsAlready
    case noAccount
}

enum NotificationType {
    case none
    case invitation
    case journey
}

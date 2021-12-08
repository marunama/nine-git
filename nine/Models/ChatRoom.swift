//
//  ChatRoom.swift
//  nine
//
//  Created by User on 2021/06/11.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoom {
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentID: String?
    var partnerUser: User?
    var groupMembers: [String]
    var groupUsers: [User] = []
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.groupMembers = dic["groupMembers"] as? [String] ?? [String]()
    }
}

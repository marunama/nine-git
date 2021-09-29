//
//  Message.swift
//  nine
//
//  Created by User on 2021/06/14.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class Message {
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    
    var partnerUser : User?
    
    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}

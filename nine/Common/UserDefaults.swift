//
//  UserDefaults.swift
//  nine
//
//  Created by Manami Ichikawa on 2021/10/23.
//

import Foundation

let notificationFcmToken = "NotificationFcmToken"

extension UserDefaults {
    
    static func save(fcmToken: String?) {
        UserDefaults.standard.set(fcmToken, forKey: notificationFcmToken)
    }

    func loadFcmToken() -> String? {
        UserDefaults.standard.string(forKey: notificationFcmToken)
    }
}

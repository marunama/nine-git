//
//  UserDefaults.swift
//  nine
//
<<<<<<< HEAD
//  Created by USER on 2021/10/24.
=======
//  Created by Manami Ichikawa on 2021/10/23.
>>>>>>> feature/save-fcmToken
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

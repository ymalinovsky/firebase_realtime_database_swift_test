//
//  App.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 05.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import Foundation
import UIKit

struct App {
    static let testUsername = "test@test.com"
    static let testPassword = "test911"
}

extension Notification.Name {
    static let newMessage = Notification.Name("newMessage")
    static let fromChatVCtoChatsVC = Notification.Name("fromChatVCtoChatsVC")
    static let newChatWasCreated = Notification.Name("newChatWasCreated")
    static let chatsVCTableViewMustBeReload = Notification.Name("chatsVCTableViewMustBeReload")
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

struct Massage {
    let sender: String
    let message: String
}

let firebase = Firebase()

var currentUser = String()

var chatsData: [Int: [Massage]]!

var availableChats = [[Int: String]]()

//
//  Chat.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 06.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import Foundation
import UIKit

class Chat {
    func addMessageToScrollView(controller: ChatViewController, sender: String, message: String) {
        let labelHeight = CGFloat(25)
        
        let label = UILabel(frame: CGRect(x: 0, y: controller.messagesScrollView.contentSize.height, width: controller.messagesScrollView.frame.size.width, height: labelHeight))
        
        label.text = "\(sender): \(message)"
        controller.messagesScrollView.addSubview(label)
        controller.messagesScrollView.contentSize = CGSize(width: controller.messagesScrollView.frame.size.width, height: label.frame.origin.y + labelHeight)
    }
}
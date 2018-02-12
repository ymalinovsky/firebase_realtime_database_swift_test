//
//  NewMessage+CoreDataProperties.swift
//  
//
//  Created by Yan Malinovsky on 12.02.2018.
//
//

import Foundation
import CoreData


extension NewMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewMessage> {
        return NSFetchRequest<NewMessage>(entityName: "NewMessage")
    }

    @NSManaged public var newMessageChatID: Int32

}

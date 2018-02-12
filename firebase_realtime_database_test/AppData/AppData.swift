//
//  AppData.swift
//  firebase_realtime_database_test
//
//  Created by Yan Malinovsky on 12.02.2018.
//  Copyright © 2018 Yan Malinovsky. All rights reserved.
//

import Foundation
import CoreData

struct AppData {
    static let coreDataNewMessageEntityName = "NewMessage"
}

func setNewMessageChatIDToCoreData(appDelegate: AppDelegate, chatID: Int) {
    let context = appDelegate.persistentContainer.viewContext
    let newMessageEntity = NSEntityDescription.entity(forEntityName: AppData.coreDataNewMessageEntityName, in: context)
    if !isSavedNewMessageChatID(appDelegate: appDelegate, chatID: chatID) {
        let newMessage = NSManagedObject(entity: newMessageEntity!, insertInto: context) as! NewMessage
        
        newMessage.newMessageChatID = Int32(chatID)
        
        // Set Data
        do {
            try context.save()
        } catch let error as NSError {
            print("Failed saving: \(error) \(error.userInfo)")
        }
    }
}

func isSavedNewMessageChatID(appDelegate: AppDelegate, chatID: Int) -> Bool {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: AppData.coreDataNewMessageEntityName)
    request.predicate = NSPredicate(format: "newMessageChatID == %@", String(describing: chatID))
    request.returnsObjectsAsFaults = false
    
    do {
        let result = try context.fetch(request)
        if result.count == 1 {
            let newMessageData = result.first as! NSManagedObject
            let newMessageChatID = newMessageData.value(forKey: "newMessageChatID") as! Int
            if newMessageChatID == chatID {
                return true
            }
        }
    } catch let error as NSError {
        print("Failed: \(error) \(error.userInfo)")
    }
    
    return false
}

func getNewMessageChatIDsFromCoreData(appDelegate: AppDelegate) -> [NewMessageChatID] {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: AppData.coreDataNewMessageEntityName)
    request.returnsObjectsAsFaults = false
    
    return getNewMessageChatIDsByRequest(context: context, request: request)
}

func getNewMessageChatIDsByRequest(context: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>) -> [NewMessageChatID] {
    var newMessagesData = [NewMessageChatID]()
    do {
        let result = try context.fetch(request)
        for data in result as! [NSManagedObject] {
            guard let newMessageChatID = data.value(forKey: "newMessageChatID") else { continue }
            // Get data
            let newMessageData = NewMessageChatID(chatID: newMessageChatID as! Int)
            newMessagesData.append(newMessageData)
        }
    } catch let error as NSError {
        print("Failed: \(error) \(error.userInfo)")
    }
    
    return newMessagesData
}

func removeNewMessageChatIDFromCoreData(appDelegate: AppDelegate, chatID: Int) {
    let context = appDelegate.persistentContainer.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: AppData.coreDataNewMessageEntityName)
    request.predicate = NSPredicate(format: "newMessageChatID == %@", String(describing: chatID))
    request.returnsObjectsAsFaults = false
    
    do {
        let result = try context.fetch(request)
        if result.count == 1 {
            let newMessageData = result.first as! NSManagedObject
            context.delete(newMessageData)
        }
    } catch let error as NSError {
        print("Detele all data in \(AppData.coreDataNewMessageEntityName) error : \(error) \(error.userInfo)")
    }
}

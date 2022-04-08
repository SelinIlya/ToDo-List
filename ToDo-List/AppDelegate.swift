//
//  AppDelegate.swift
//  ToDo-List
//
//  Created by Ilya Selin on 17.03.2022.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        do {
            _ = try Realm()
        } catch {
            print("Error init Realm, \(error)")
        }
        
        return true
    }
//    print(Realm.Configuration.defaultConfiguration.fileURL) // Место хранения
}
 

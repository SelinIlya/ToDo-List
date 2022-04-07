//
//  Category.swift
//  ToDo-List
//
//  Created by Ilya Selin on 07.04.2022.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}

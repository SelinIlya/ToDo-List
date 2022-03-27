//
//  Item.swift
//  ToDo-List
//
//  Created by Ilya Selin on 27.03.2022.
//

import Foundation

class Item: Encodable {
    var title: String = ""
    var done: Bool = false 
}

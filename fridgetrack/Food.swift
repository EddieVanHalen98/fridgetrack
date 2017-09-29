//
//  Food.swift
//  fridgetrack
//
//  Created by James Saeed on 16/09/2017.
//  Copyright © 2017 evh98. All rights reserved.
//

import Foundation

class Food {
    
    var id: String?
    var name: String?
    var quantity: Int?
    var expiryDate: String?
    var expiryDays: Int?
    
    init (id: String, name: String, quantity: Int, expiryDate: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expiryDate = expiryDate
    }
}

//
//  User.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/3/21.
//

import Foundation

struct TaskyUser: Identifiable, Codable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    
    var fullName:String{
        firstName + " " + lastName
    }
}

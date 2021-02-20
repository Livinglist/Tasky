//
//  Task.swift
//  Tasky
//
//  Created by Jiaqi Feng on 2/3/21.
//

import Foundation
import FirebaseFirestoreSwift

enum TaskStatus: Int, Codable, CustomStringConvertible{
    case awaiting
    case inProgress
    case completed
    case aborted
    
    var description : String {
        switch self {
        case .awaiting: return "Awaiting"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .aborted: return "Aborted"
        }
    }
}

struct Task: Identifiable, Codable, Equatable{
    var id: String
    var title: String
    var content: String
    var taskStatus: TaskStatus
    var timestamp: Double
    var dueTimestamp: Double?
    var creatorId: String?
    var assigneesId: [String]?
    var tags: [String: String]?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
    }
}

let testTask = Task(id: "", title: "", content: "", taskStatus: .awaiting, timestamp: 0, dueTimestamp: nil, creatorId: nil, assigneesId: [])

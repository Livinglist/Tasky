//
//  Project.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Project: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var tasks: [Task]
    var managerId: String?
    var collaboratorIds: [String]?
    var timestamp: Double
    var tags: [String: String]?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
    }
}

#if DEBUG
let testProject = Project(id: UUID().uuidString, name: "Huge Project", tasks: [], managerId: nil, collaboratorIds: [], timestamp: Date().timeIntervalSince1970)

let testData = (1...10).map { i in
    Project(name: "Project #\(i)", tasks: [Task(id: "\(i)", title: "Task \(i)", content: "content of a task", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)], managerId: "test", timestamp: NSDate().timeIntervalSince1970)
}
#endif

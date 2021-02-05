//
//  Project.swift
//  Tasky
//
//  Created by Jiaqi Feng on 1/29/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Project: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var tasks: [Task]
    var userId: String?
}

#if DEBUG
let testData = (1...10).map { i in
    Project(name: "Question #\(i)", tasks: [Task(id: "\(i)", title: "Task \(i)", content: "content of a task", taskStatus: .awaiting, timestamp: NSDate().timeIntervalSince1970)], userId: "test")
}
#endif

//
//  SwitchTask.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation
import Swiftline
import KanbanizeAPI
import Locksmith

final class SwitchTask: Command {
  fileprivate static let service = "SwitchTask"
  fileprivate let args: ParsedArgs
  init(args: ParsedArgs) {
    self.args = args
  }
  
  func execute(_ completion: @escaping CommandCompletion) throws {
    guard let taskID = args.parameters.dropFirst().first else { throw CommandError.wrongCommandConfiguration(command: self) }
    
    try Locksmith.updateData(data: [Params.TaskID.rawValue: taskID],
                             forUserAccount: locksmithAccountName,
                             inService: SwitchTask.service)
    
    completion(Result.success("Task Switched: \(taskID)"))
  }
  
  static var name: String { return "switch_task" }
  
  enum Params: String {
    case TaskID = "task_id"
  }
  
  enum SwitchTaskError: Error {
    case taskNotSelected
  }
  
  internal static func currentTask() throws -> TaskID {
    guard let data = Locksmith.loadDataForUserAccount(userAccount: locksmithAccountName, inService: SwitchTask.service),
      let task_id = data[Params.TaskID.rawValue] as? String else {
      throw SwitchTaskError.taskNotSelected
    }
    
    return TaskID(task_id)
  }
}

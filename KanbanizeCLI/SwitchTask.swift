//
//  SwitchTask.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

final class SwitchTask: Command {
  private static let service = "SwitchTask"
  private let args: ParsedArgs
  init(args: ParsedArgs) {
    self.args = args
  }
  
  func execute(completion: CommandCompletion) throws {
    guard let taskID = args.parameters.dropFirst().first else { throw CommandError.WrongCommandConfiguration(command: self) }
    
    try Locksmith.updateData([Params.TaskID.rawValue: taskID],
                             forUserAccount: locksmithAccountName,
                             inService: SwitchTask.service)
    
    completion(message: Result.Success("Task Switched: \(taskID)"))
  }
  
  static var name: String { return "switch_task" }
  
  enum Params: String {
    case TaskID = "task_id"
  }
  
  enum SwitchTaskError: ErrorType {
    case TaskNotSelected
  }
  
  internal static func currentTask() throws -> TaskID {
    guard let data = Locksmith.loadDataForUserAccount(locksmithAccountName, inService: SwitchTask.service),
      let task_id = data[Params.TaskID.rawValue] as? String else {
      throw SwitchTaskError.TaskNotSelected
    }
    
    return TaskID(task_id)
  }
}
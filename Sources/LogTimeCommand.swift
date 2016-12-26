//
//  LogTimeCommand.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/30/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation
import Swiftline
import KanbanizeAPI

final class LogTimeCommand: Command {
  fileprivate let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var client: Client?
  
  func execute(_ completion: @escaping CommandCompletion) throws {
    let timeString = args.parameters.dropFirst().joined(separator: " ")
    
    guard let hours = Double(timeString) else { throw CommandError.wrongCommandConfiguration(command: self) }
    
    do {
      let client = try LoginCommand.createClient()
      self.client = client
      
      let taskID = try SwitchTask.currentTask()
      try client.logTime(LoggedTime(hours: hours), taskID: taskID) {
        (result: Result<Client.LogTimeResult, ClientError>) in
        switch result {
        case .success(let logTimeResult):
          completion(Result.success("\(logTimeResult)"))
        case .failure(let clientError):
          completion(Result.failure(CommandError.unknownError(clientError)))
        }
      }
    }
    catch {
      completion(Result.failure(CommandError.unknownError(error)))
    }
  }
  
  static var name: String { return "time" }
}

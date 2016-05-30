//
//  LogTimeCommand.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/30/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

final class LogTimeCommand: Command {
  private let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var client: Client?
  
  func execute(completion: CommandCompletion) throws {
    let timeString = args.parameters.dropFirst().joinWithSeparator(" ")
    
    guard let hours = Double(timeString) else { throw CommandError.WrongCommandConfiguration(command: self) }
    
    do {
      let client = try LoginCommand.createClient()
      self.client = client
      
      let taskID = try SwitchTask.currentTask()
      try client.logTime(LoggedTime(hours: hours), taskID: taskID) {
        (result: Result<Client.LogTimeResult, ClientError>) in
        switch result {
        case .Success(let logTimeResult):
          completion(message: Result.Success("\(logTimeResult)"))
        case .Failure(let clientError):
          completion(message: Result.Failure(CommandError.UnknownError(clientError)))
        }
      }
    }
    catch {
      completion(message: Result.Failure(CommandError.UnknownError(error)))
    }
  }
  
  static var name: String { return "time" }
}
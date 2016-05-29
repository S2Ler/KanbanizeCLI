//
//  AddComment.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

final class AddCommentCommand: Command {
  private let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var client: Client?
  
  func execute(completion: CommandCompletion) throws {
    let comment = args.parameters.dropFirst().joinWithSeparator(" ")
    
    do {
      let client = try LoginCommand.createClient()
      self.client = client
      
      let taskID = try SwitchTask.currentTask()
      
      try client.addComment(comment, taskID: taskID) {
        (result: Result<Client.AddCommentResult, ClientError>) in
        switch result {
        case .Success(let addCommentResult):
          print(addCommentResult)
          completion(message: Result.Success("Added"))
        case .Failure(let clientError):
          completion(message: Result.Failure(CommandError.UnknownError(clientError)))
        }
      }
    }
    catch {
      completion(message: Result.Failure(CommandError.UnknownError(error)))
    }
  }
  
  static var name: String { return "comment" }
}
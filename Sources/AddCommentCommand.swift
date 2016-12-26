//
//  AddComment.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation
import Swiftline
import KanbanizeAPI

final class AddCommentCommand: Command {
  fileprivate let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var client: Client?
  
  func execute(_ completion: @escaping CommandCompletion) throws {
    let comment = args.parameters.dropFirst().joined(separator: " ")
    
    do {
      let client = try LoginCommand.createClient()
      self.client = client
      
      let taskID = try SwitchTask.currentTask()
      
      try client.addComment(comment, taskID: taskID) {
        (result: Result<Client.AddCommentResult, ClientError>) in
        switch result {
        case .success(let addCommentResult):
          completion(Result.success("\(addCommentResult)"))
        case .failure(let clientError):
          completion(Result.failure(CommandError.unknownError(clientError)))
        }
      }
    }
    catch {
      completion(Result.failure(CommandError.unknownError(error)))
    }
  }
  
  static var name: String { return "comment" }
}

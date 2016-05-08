//
//  Login.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

final class LoginCommand: Command {
  let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var kanbanizeClient: Client?
  
  func execute(completion: (message: Result<String, CommandError>) -> ()) throws {
    if let apiKey = args.flags[Params.APIKey.rawValue],
       let subdomain = args.flags[Params.Subdomain.rawValue] {
      try saveLoginInfo(apiKey: apiKey, subdomain: subdomain)
      completion(message: Result.Success(Message.LoggedIn.rawValue))
    }
    else if let email = args.flags[Params.Email.rawValue],
       let password = args.flags[Params.Password.rawValue],
       let subdomain = args.flags[Params.Subdomain.rawValue] {
      
      let kanbanizeClient = Client(subdomain: subdomain, loginInfo: Client.LoginInfo.Password(email: email, password: password))
      self.kanbanizeClient = kanbanizeClient
      
      kanbanizeClient.login({ result in
        switch result {
        case .Success(let loginResult):
          if let apiKey = loginResult?.apiKey {
            do {
              try self.saveLoginInfo(apiKey: apiKey, subdomain: subdomain)
              completion(message: Result.Success(Message.LoggedIn.rawValue))
            }
            catch {
              completion(message: Result.Failure(CommandError.UnknownError(error)))
            }
          }
        case .Failure(let error):
          completion(message: Result.Failure(CommandError.UnknownError(error)))
        }
      })      
    }
    else {
      throw CommandError.WrongCommandConfiguration(command: self)
    }
  }
  
  static var name: String { return "login" }
  
  private func saveLoginInfo(apiKey apiKey: String, subdomain: String) throws {
    try Locksmith.updateData([Params.APIKey.rawValue: apiKey],
                             forUserAccount: locksmithAccountName)
  }
  
  enum Params: String {
    case APIKey = "api_key"
    case Email = "email"
    case Password = "password"
    case Subdomain = "subdomain"
  }
  
  private enum Message: String {
    case LoggedIn = "Logged In"
  }

}
//
//  Login.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

final class LoginCommand: Command {
  private static let service = "LoginInfo"
  private let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var kanbanizeClient: Client?

  func execute(completion: CommandCompletion) throws {
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
      try loginWithClient(kanbanizeClient, completion: completion)
    }
    else {
      throw CommandError.WrongCommandConfiguration(command: self)
    }
  }
  
  private func loginWithClient(client: Client, completion: CommandCompletion) throws {
    client.login { result in
      switch result {
      case .Success(let loginResult):
        if let apiKey = loginResult?.apiKey {
          do {
            try self.saveLoginInfo(apiKey: apiKey, subdomain: client.subdomain)
            let message = loginResult != nil ? "\(loginResult!)" : Message.LoggedIn.rawValue
            completion(message: Result.Success(message))
          }
          catch {
            completion(message: Result.Failure(CommandError.UnknownError(error)))
          }
        }
      case .Failure(let error):
        completion(message: Result.Failure(CommandError.UnknownError(error)))
      }
    }
  }
  
  static var name: String { return "login" }
  
  private func saveLoginInfo(apiKey apiKey: String, subdomain: String) throws {
    try Locksmith.updateData([Params.APIKey.rawValue: apiKey, Params.Subdomain.rawValue: subdomain],
                             forUserAccount: locksmithAccountName,
                             inService: LoginCommand.service)
  }
    
  static internal func createClient() throws -> Client {
    guard let data = Locksmith.loadDataForUserAccount(locksmithAccountName, inService: LoginCommand.service) else {
      throw LoginError.NotLoggedIn
    }
    
    if let apiKey = data[Params.APIKey.rawValue] as? String,
      let subdomain = data[Params.Subdomain.rawValue] as? String {
      return Client(subdomain: subdomain, loginInfo: .APIKey(apiKey))
    }
    else {
      throw LoginError.NotLoggedIn
    }
  }
  
  enum LoginError: ErrorType {
    case NotLoggedIn
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


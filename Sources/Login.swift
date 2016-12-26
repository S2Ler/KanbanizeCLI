//
//  Login.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 5/8/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation
import Swiftline
import KanbanizeAPI
import Locksmith

final class LoginCommand: Command {
  fileprivate static let service = "LoginInfo"
  fileprivate let args: ParsedArgs
  
  init(args: ParsedArgs) {
    self.args = args
  }
  
  var kanbanizeClient: Client?

  func execute(_ completion: @escaping CommandCompletion) throws {
    if let apiKey = args.flags[Params.APIKey.rawValue],
       let subdomain = args.flags[Params.Subdomain.rawValue] {
      try saveLoginInfo(apiKey: apiKey, subdomain: subdomain)
      completion(Result.success(Message.LoggedIn.rawValue))
    }
    else if let email = args.flags[Params.Email.rawValue],
       let password = args.flags[Params.Password.rawValue],
       let subdomain = args.flags[Params.Subdomain.rawValue] {
      
      let kanbanizeClient = Client(subdomain: subdomain, loginInfo: Client.LoginInfo.password(email: email, password: password))
      self.kanbanizeClient = kanbanizeClient
      try loginWithClient(kanbanizeClient, completion: completion)
    }
    else {
      throw CommandError.wrongCommandConfiguration(command: self)
    }
  }
  
  fileprivate func loginWithClient(_ client: Client, completion: @escaping CommandCompletion) throws {
    client.login { result in
      switch result {
      case .success(let loginResult):
        if let apiKey = loginResult?.apiKey {
          do {
            try self.saveLoginInfo(apiKey: apiKey, subdomain: client.subdomain)
            let message = loginResult != nil ? "\(loginResult!)" : Message.LoggedIn.rawValue
            completion(Result.success(message))
          }
          catch {
            completion(Result.failure(CommandError.unknownError(error)))
          }
        }
      case .failure(let error):
        completion(Result.failure(CommandError.unknownError(error)))
      }
    }
  }
  
  static var name: String { return "login" }
  
  fileprivate func saveLoginInfo(apiKey: String, subdomain: String) throws {
    try Locksmith.updateData(data: [Params.APIKey.rawValue: apiKey, Params.Subdomain.rawValue: subdomain],
                             forUserAccount: locksmithAccountName,
                             inService: LoginCommand.service)
  }
    
  static internal func createClient() throws -> Client {
    guard let data = Locksmith.loadDataForUserAccount(userAccount: locksmithAccountName, inService: LoginCommand.service) else {
      throw LoginError.notLoggedIn
    }
    
    if let apiKey = data[Params.APIKey.rawValue] as? String,
      let subdomain = data[Params.Subdomain.rawValue] as? String {
      return Client(subdomain: subdomain, loginInfo: .apiKey(apiKey))
    }
    else {
      throw LoginError.notLoggedIn
    }
  }
  
  enum LoginError: Error {
    case notLoggedIn
  }
  
  enum Params: String {
    case APIKey = "api_key"
    case Email = "email"
    case Password = "password"
    case Subdomain = "subdomain"
  }
  
  fileprivate enum Message: String {
    case LoggedIn = "Logged In"
  }
}


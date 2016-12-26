//
//  Commands.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation
import Swiftline
import KanbanizeAPI

typealias CommandCompletion = (_ message: Result<String, CommandError>) -> ()

protocol Command {
  init(args: ParsedArgs)
  func execute(_ completion: @escaping CommandCompletion) throws
  static var name: String { get }
}

enum CommandError: Error {
  case missingCommandName
  case unsupportedCommandName(String)
  case wrongCommandConfiguration(command: Command)
  case unknownError(Error)
}

final class CommandFactory {
  typealias CommandName = String
  fileprivate static var commands: [CommandName: Command.Type] = [:]
  
  static func registerCommandType(_ commandType: Command.Type) {
    commands[commandType.name] = commandType
  }
  
  static func makeCommand(_ args: ParsedArgs) throws -> Command {
    guard let commandName = args.parameters.first else { throw CommandError.missingCommandName }
    
    guard let commandType = commands[commandName] else { throw CommandError.unsupportedCommandName(commandName) }
    
    return commandType.init(args: args)
  }
}

//
//  Commands.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

protocol Command {
  init(args: ParsedArgs)
  func execute(completion: (message: Result<String, CommandError>) -> ()) throws
  static var name: String { get }
}

enum CommandError: ErrorType {
  case MissingCommandName
  case UnsupportedCommandName(String)
  case WrongCommandConfiguration(command: Command)
  case UnknownError(ErrorType)
}

final class CommandFactory {
  typealias CommandName = String
  private static var commands: [CommandName: Command.Type] = [:]
  
  static func registerCommandType(commandType: Command.Type) {
    commands[commandType.name] = commandType
  }
  
  static func makeCommand(args: ParsedArgs) throws -> Command {
    guard let commandName = args.parameters.first else { throw CommandError.MissingCommandName }
    
    guard let commandType = commands[commandName] else { throw CommandError.UnsupportedCommandName(commandName) }
    
    return commandType.init(args: args)
  }
}

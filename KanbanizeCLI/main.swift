//
//  main.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

func runUntil(finished finished: () -> Bool) {
  while !finished() {
    NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.25))
  }
}

let locksmithAccountName = "KanbanizeCLI"

if Args.parsed.parameters.contains("help") {
  exit(0)
}

let args = Args.parsed

let supportedCommandTypes = [LoginCommand.self, SwitchTask.self, AddCommentCommand.self]

for commandType in supportedCommandTypes {
  guard let commandType = commandType as? Command.Type else { preconditionFailure() }
  CommandFactory.registerCommandType(commandType)
}

do {
  let command = try CommandFactory.makeCommand(args)
  var finished = false
  try command.execute({ (message) in
    switch message {
    case .Success(let message):
      print("Success: \(message)")
    case .Failure(let error):
      print("Error: \(error)")
    }
    finished = true
  })
  runUntil(finished: { () -> Bool in
    return finished
  })
}
catch {
  print(error)
}

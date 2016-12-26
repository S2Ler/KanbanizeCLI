//
//  main.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation
import Swiftline
import KanbanizeAPI

func runUntil(finished: () -> Bool) {
  while !finished() {
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
  }
}

let locksmithAccountName = "KanbanizeCLI"

if Args.parsed.parameters.contains("help") {
  exit(0)
}

let args = Args.parsed

let supportedCommandTypes = [LoginCommand.self, SwitchTask.self, AddCommentCommand.self, LogTimeCommand.self] as [Any]

for commandType in supportedCommandTypes {
  guard let commandType = commandType as? Command.Type else { preconditionFailure() }
  CommandFactory.registerCommandType(commandType)
}

do {
  let command = try CommandFactory.makeCommand(args)
  var finished = false
  try command.execute({ (message) in
    switch message {
    case .success(let message):
      print("Success: \(message)")
    case .failure(let error):
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

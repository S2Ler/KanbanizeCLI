//
//  main.swift
//  KanbanizeCLI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

if Args.parsed.parameters.contains("help") {
  exit(0)
}

let flags = Args.parsed.flags
guard let apiKey = flags["api_key"],
  let domain = flags["domain"] else { exit(-1) }

let client = Client(subdomain: domain, loginInfo: .APIKey(apiKey))
client.login { (result) in
  print(result)
}

NSRunLoop.currentRunLoop().run()

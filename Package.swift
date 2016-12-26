import PackageDescription

/// The package description.
let package = Package(
  name: "KanbanizeCLI",
  targets: [],
  dependencies: [
    .Package(url: "https://github.com/oarrabi/Swiftline", majorVersion: 0, minor: 5),
    .Package(url: "https://github.com/diejmon/Locksmith", majorVersion: 3, minor: 0),
    .Package(url: "https://github.com/diejmon/KanbanizeAPI", majorVersion: 0, minor: 1)
  ]
)

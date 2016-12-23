import PackageDescription

let package = Package(
    name: "MyAwesomeProject",
    targets: [

  	],
  	dependencies: [
  		.Package(url:"https://github.com/PerfectlySoft/PerfectLib.git", majorVersion: 2, minor: 0),
  		.Package(url:"https://github.com/PerfectlySoft/Perfect-HTTP.git", majorVersion: 2, minor: 0),
  		.Package(url:"https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2, minor: 0),
      .Package(url:"https://github.com/PerfectlySoft/Perfect-SQLite.git", majorVersion: 2, minor: 0),
  		.Package(url:"https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 0)
  	]
)

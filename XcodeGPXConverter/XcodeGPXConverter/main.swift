//
//  main.swift
//  XcodeGPXConverter
//
//  Created by Oleksii on 09.09.22.
//

import Foundation

var inputFileName: String?
var outputFileName: String?
var timeInterval: Int?

for i in 0..<CommandLine.arguments.count {
  if i == 1 {
    inputFileName = CommandLine.arguments[i]
  }
  if i == 2 {
    outputFileName = CommandLine.arguments[i]
  }
  if i == 3 {
    timeInterval = Int(CommandLine.arguments[i])
  }
}

guard
  CommandLine.arguments.count > 0,
  let inputFile = inputFileName,
  let outputFile = outputFileName,
  let interval = timeInterval
else {
  print("   ERROR: provide input file name, output file name and time interval between locations in seconds")
  exit(1)
}

let fileManager = FileManager()
var isDirectory: ObjCBool = false
guard
  fileManager.fileExists(atPath: inputFile, isDirectory: &isDirectory),
  inputFile.suffix(3).lowercased() == "gpx"
else {
  print("   ERROR: please provide a valid path to input GPX file")
  exit(1)
}

guard isDirectory.boolValue == false else {
  print("   ERROR: input must be GPX 1.1 file, not a folder")
  exit(1)
}
let startTime = Date()
print("Conversion of GPX file started...")

XcodeGPXConverter().convert(inputFileName: inputFile, outputFileName: outputFile, locationsInterval: interval)

print("Conversion of GPX file finished in \(Date().timeIntervalSince(startTime)) seconds.")



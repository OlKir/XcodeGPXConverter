//
//  XcodeGPXConvertor.swift
//  XcodeGPXConverter
//
//  Created by Oleksii on 09.09.22.
//

import Foundation


struct XcodeGPXWaypoint {
  let latitude: Double
  let longitude: Double
  let timestamp: Date
  
  func formattedString(with dateFormatter: ISO8601DateFormatter) -> String {
    var gpxWaypointLines: [String] = []
    let coordinateLine = "<wpt lat=\"\(self.latitude)\" lon=\"\(self.longitude)\">"
    gpxWaypointLines.append(coordinateLine)
    gpxWaypointLines.append("<ele>150.0</ele>")
    let timeLine = "<time>" + dateFormatter.string(from: self.timestamp) + "</time>"
    gpxWaypointLines.append(timeLine)
    gpxWaypointLines.append("</wpt>")
    return gpxWaypointLines.joined(separator: "\n")
  }
}

final class XcodeGPXConverter {
  
  private let header: String = """
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Xcode">
"""
  private let footer: String = "</gpx>"
  
  private lazy var dateFormatter: ISO8601DateFormatter = {
    let dateFormatter = ISO8601DateFormatter()
    return dateFormatter
  }()
  
  func convert(inputFileName: String, outputFileName: String, locationsInterval: Int) {
    let inputFileURL = URL(fileURLWithPath: inputFileName)
    var inputContent: String?
    
    do {
      let data = try Data(contentsOf: inputFileURL)
      inputContent = String(data: data, encoding: .utf8)
    } catch {
      print("   ERROR: file at \(inputFileURL.absoluteString) can't be loaded: \(error)")
      exit(1)
    }
    
    guard let inputFileContent = inputContent else {
      print("   ERROR: input has encoding different from utf8")
      exit(1)
    }
    
    let inputLines = inputFileContent.split(separator: "\n")
    guard inputLines.count > 3 else {
      print("   ERROR: input file doesn't separated in lines")
      exit(1)
    }
    
    let startDate = Date()
    
    var output: [String] = []
    
//    let coordinateSearch = /<trkpt lat="(.+?)" lon="(.+?)"><ele>0<\/ele><\/trkpt>/
    
    let latPattern = "lat=\"[0-9]*.[0-9]*\""
    let lonPattern = "lon=\"[0-9]*.[0-9]*\""
    
    for i in 0..<inputLines.count {
      let inputLine = inputLines[i].trimmingCharacters(in: .whitespacesAndNewlines)
      guard
        let latRange = inputLine.range(of: latPattern, options: .regularExpression),
        let lonRange = inputLine.range(of: lonPattern, options: .regularExpression)
      else {
        continue
      }
      let latSubstring = inputLine.substring(with: latRange)
      let startLatIndex = latSubstring.index(latSubstring.startIndex, offsetBy: 5)
      let endLatIndex = latSubstring.index(latSubstring.endIndex, offsetBy: -2)
      let latString = latSubstring[startLatIndex...endLatIndex]
      
      let lonSubstring = inputLine.substring(with: lonRange)
      let startLonIndex = lonSubstring.index(lonSubstring.startIndex, offsetBy: 5)
      let endLonIndex = lonSubstring.index(lonSubstring.endIndex, offsetBy: -2)
      let lonString = lonSubstring[startLonIndex...endLonIndex]
      
//      guard let coordinates = try? coordinateSearch.wholeMatch(in: inputLine) else {
//        continue
//      }
      guard
        let latitude = Double(latString),
        let longitude = Double(lonString)
      else {
        continue
      }
      let interval = Double(locationsInterval * i)
      let locationDate = Date(timeInterval: interval, since: startDate)
      let waypoint = XcodeGPXWaypoint(latitude: latitude, longitude: longitude, timestamp: locationDate)
      output.append(waypoint.formattedString(with: self.dateFormatter))
    }
    
    output.insert(header, at: 0)
    output.append(footer)
    
    let outputFileContent = output.joined(separator: "\n")
    let outputFileData = outputFileContent.data(using: .utf8)
    let outputFileURL = URL(fileURLWithPath: outputFileName)
    
    do {
      try outputFileData?.write(to: outputFileURL)
    } catch {
      print("   ERROR: output file can't be written: \(error)")
      exit(1)
    }
  }
}

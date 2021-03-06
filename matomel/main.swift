//
//  main.swift
//  matomel
//
//  Created by mochix.yuzgit on 2021/06/24.
//

import Foundation
import ArgumentParser

struct Matomel: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "matomel",
        abstract: "Matomel is a tool that moves files on your desktop that haven't been updated for a long time to an archive folder.",
//        discussion: "",
        version: "0.9.0",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )
    
    @Option(
        name: .shortAndLong,
        help: ""
    )
    var countDate: Int = 30
    
    func run() throws {
        let filename: String = "archive"
        let filenameAddedDate: String = filename + "_" + getCurrentDate()
        let fileManager: AnyObject = FileManager.default
        let desktopDirectoryPath: URL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
        let archiveDirectoryPath: URL = desktopDirectoryPath.appendingPathComponent(filenameAddedDate)
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: NSHomeDirectory() + "/Desktop")
            let targetFileList = fileList.filter { judgeTargetFile(filename: $0) }

            try createDirectory(path: archiveDirectoryPath)
            try targetFileList.forEach {
                try moveFile(
                    fromPath: desktopDirectoryPath.appendingPathComponent($0),
                    toPath: archiveDirectoryPath.appendingPathComponent($0)
                )
            }
        } catch {
            print(error)
        }
    }

    func getCurrentDate() -> String {
        let date: Date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd_HHmmss"
        return format.string(from: date)
    }
    
    func createDirectory(path: URL) throws {
        let fileManager: AnyObject = FileManager()
        
        do {
            try fileManager.createDirectory(
                at: path,
                withIntermediateDirectories: false,
                attributes: nil
            )
        }
    }
    
    func judgeTargetFile(filename: String) -> Bool {
        let fileManager: AnyObject = FileManager()

        do {
            // judge: filename
            if filename.contains("archive_") {
                return false
            }
            
            // judge: compare countDate
            let now = NSDate()
            let attributes = try fileManager.attributesOfItem(atPath: NSHomeDirectory() + "/Desktop/" + filename)
            let fileUpdatedDate = attributes[.modificationDate]!
            let diff = Calendar.current.dateComponents([.day], from: fileUpdatedDate as! Date, to: now as Date).day
            return diff! > countDate
        } catch {
            print(error)
            return false
        }
    }
    
    func moveFile(fromPath: URL, toPath: URL) throws {
        let fileManager: AnyObject = FileManager()

        do {
            try fileManager.moveItem(at: fromPath, to: toPath)
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

Matomel.main()

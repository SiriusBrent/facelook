//
//  Miscellaneous.swift
//  FaceLook
//
//  Created by Brent on 2015-12-04.
//  Copyright © 2015 Brent Marykuca. All rights reserved.
//

import Foundation
import UIKit

func random(max:Int) -> Int
{
    return Int(arc4random() % UInt32(max))
}

// Look up a localizable string using the string itself as a key but prefixed with the emoji character "❌"
// This is intended to make it easier to find strings that are missing from the localization files because they will
// have this character prefixed when they show up in the UI.

func LocalizedString(str: String, comment:String) -> String
{
    return NSLocalizedString(str, comment: comment)
}

func LocalizedString(str: String) -> String
{
    return LocalizedString("❌" + str, comment: str)
}

extension String
{
    // String Utilities
    
    func trimWhitespace() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    // Numeric Utilities
    
    var doubleValue: Double
    {
        return (self as NSString).doubleValue
    }
    
    // Path Utilities
    
    var parentPath: String
    {
        return (self as NSString).stringByDeletingLastPathComponent
    }

    // This will do the right thing if the string contains a decomposed character. (e.g. "e\u{0301}")
    func substringFromCharacterIndex(index: Int) -> String
    {
        let startIndex = self.characters.startIndex.advancedBy(index)
        let endIndex = self.characters.endIndex
        return String(self.characters[startIndex ..< endIndex])
    }
}

// Miscellaneous global functions that hopefully make code more readable. Note that these functions err on
// the side of simplicity and readability and may not always be safe to use where edge cases might exist.

func FolderExistsAtURL(url: NSURL) -> Bool
{
    var isDirectory: ObjCBool = false
    var exists = false
    if let urlPath = url.path
    {
        exists = NSFileManager.defaultManager().fileExistsAtPath(urlPath, isDirectory: &isDirectory)
    }
    return exists && isDirectory
}

func FileExistsAtURL(url: NSURL) -> Bool
{
    var isDirectory: ObjCBool = false
    var exists = false
    if let urlPath = url.path
    {
        exists = NSFileManager.defaultManager().fileExistsAtPath(urlPath, isDirectory: &isDirectory)
    }
    return exists && (Bool(isDirectory) == false)
}

func EnsureFolderExistsAtURL(url: NSURL)
{
    if FolderExistsAtURL(url) == false
    {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            LogError(error)
        }
    }
}

func FileExistsAtPath(path:String) -> Bool
{
    var isDirectory: ObjCBool = false
    let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
    
    return exists && !isDirectory
}

func FolderExistsAtPath(path:String) -> Bool
{
    var isDirectory: ObjCBool = false
    let exists = NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory)
    
    return exists && isDirectory
}

func EnsureFolderExistsAtPath(folderPath: String)
{
    if FolderExistsAtPath(folderPath) == false
    {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: folderPath), withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            LogError(error)
        }
    }
}

// Removes files and folders (including recursive contents of folders).
func RemoveItemAtPath(filePath: String)
{
    do {
        try NSFileManager.defaultManager().removeItemAtPath(filePath)
    }
    catch let error as NSError {
        LogError(error)
    }
}


private var documentsFolderURL: NSURL! = {

    do {
        return try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
    }
    catch {
        fatalError("Cannot get a reference to the documents folder.")
    }
} ()

func DocumentsFolderURL(name: String? = nil) -> NSURL
{
    if let childName = name {
        return documentsFolderURL.URLByAppendingPathComponent(childName)
    } else {
        return documentsFolderURL
    }
}

extension NSURL
{
    var parentFolderURL: NSURL
    {
        return self.URLByAppendingPathComponent("..") // Surprisingly, this works.
    }
    
    func URLByAppendingPathComponents(components: [String]) -> NSURL
    {
        return self.URLByAppendingPathComponent(components.joinWithSeparator("/")).URLByStandardizingPath!
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func runLaterOnMainQueue(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func runOnMainQueue(closure:()->())
{
    dispatch_async(dispatch_get_main_queue(), closure)
}


func prefixLines(prefix: String, lines: [String]) -> [String]
{
    return lines.map({ prefix + $0 })
}

func indent(lines: [String]) -> [String]
{
    return prefixLines("    ", lines: lines)
}

func printLines(lines:[String])
{
    print(lines.joinWithSeparator("\n"))
}

@noreturn func halt(reason: String = "", file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__)
{
    NSLog("## HALT: \(reason) in \(function)")
    NSLog("##  AT: \(file):\(line)")
    abort()
}

// Feels like there's an opportunity here to make this generic.

class TextViewChangeObserver
{
    var observerObject: NSObjectProtocol

    init(_ textView: UITextView, action: () -> ()) {
        observerObject = NSNotificationCenter.defaultCenter().addObserverForName(UITextViewTextDidChangeNotification, object: textView, queue: nil)
        { note in
            action()
        }
    }

    func stopObserving()
    {
        NSNotificationCenter.defaultCenter().removeObserver(observerObject)
    }
    
    deinit {
        print("-- deinit Change observer")
    }
}

//  Use these, for example in a View Controller, like this:
//
//    let observerObject: TextFieldChangeObserver!

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        observerObject = TextFieldChangeObserver(fieldToObserve) { [unowned self] in
//            ...
//        }
//    }
//
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        observerObject.stopObserving()
//    }

class TextFieldChangeObserver
{
    // NOTE: We seem to be getting two notifications for each change here.
    var observerObject: NSObjectProtocol

    init(_ textField:UITextField, action: () -> ()) {
        observerObject = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: nil)
        { note in
            action()
        }
    }

    func stopObserving()
    {
        NSNotificationCenter.defaultCenter().removeObserver(observerObject)
    }
}

extension Set
{
    // This is a horrible name, but I can't think of a better one right now.
    // Make sure that a particular set member either does or does not exist in the set
    mutating func setMember(member:Element, isPresent present: Bool)
    {
        if present
        {
            self.insert(member)
        }
        else
        {
            self.remove(member)
        }
    }
}


func LoremIpsum(lines: Int = 1) -> String
{
    var result = ""
    let text = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "Donec a diam lectus.", "Sed sit amet ipsum mauris.", "Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit.", "Donec et mollis dolor.", "Praesent et diam eget libero egestas mattis sit amet vitae augue.", "Nam tincidunt congue enim, ut porta lorem lacinia consectetur.", "Donec ut libero sed arcu vehicula ultricies a non tortor.", "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "Aenean ut gravida lorem.", "Ut turpis felis, pulvinar a semper sed, adipiscing id dolor.", "Pellentesque auctor nisi id magna consequat sagittis.", "Curabitur dapibus enim sit amet elit pharetra tincidunt feugiat nisl imperdiet.", "Ut convallis libero in urna ultrices accumsan.", "Donec sed odio eros.", "Donec viverra mi quis quam pulvinar at malesuada arcu rhoncus.", "Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", "In rutrum accumsan ultricies.", "Mauris vitae nisi at sem facilisis semper ac in est.\n"]
    
    for i in 0..<lines
    {
        if i > 0
        {
            result += " "
        }
        result = result + text[i % text.count]
    }
    return result
}

func Trace(note:String = "", function: String = __FUNCTION__, line: Int = __LINE__)
{
    let separator = (note == "") ? "" : " "
    print("TRACE: \(note)\(separator)\(function):\(line)")
}

// MARK: Error Logging

func NoteError(error: NSError, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__)
{
    NSLog("")
    NSLog("## \(file) \(line):\(column) (\(function))")
    NSLog("## ERROR \(error.domain) \(error.code) \(error.localizedDescription)")
}

typealias ErrorLoggingFunction = (NSError) -> Void

private var errorLoggingFunctionsByDomain: [String:ErrorLoggingFunction] = [:]

func SetLoggingFunction(function: ErrorLoggingFunction, forErrorDomain domain: String)
{
    errorLoggingFunctionsByDomain[domain] = function
}

func LogError(error: NSError!, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__)
{
    if error != nil
    {
        print("")
        print("## \(file) \(line):\(column) (\(function))")
        if let logMethod = errorLoggingFunctionsByDomain[error.domain]
        {
            logMethod(error)
        }
        else
        {
            NSLog("")
            NSLog("## Error in Unhandled Domain: \(error.domain)")
            NSLog("## Code: \(error.code)")
            NSLog("## Description: \(error.localizedDescription)")
            NSLog("## UserInfo: \(error.userInfo)")
        }
    }
}


//
//  ExtensionString.swift
//  DemoSwift
//
//  Created by mac-0007 on 27/09/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func trim() -> String?
    {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func blank() -> Bool
    {
        return self.trim()!.characters.count == 0
    }
    
    func validEmail() -> Bool
    {
        
        let regex = "^[+\\w\\.\\-']+@[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self.trim())
    }
    
    func validPhone() -> Bool
    {
        if(self.characters.count < 14)
        {
            return false
        }
        return true
        
        let regex = "^((\\+)|(00))[0-9]{6,14}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self.trim())
    }
    
    func validPassword() -> Bool
    {
        return (self.trim()?.count)!>=6
    }
    
    func validNumber() -> Bool
    {
        let regex = "[0-9]"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self.trim())
    }
    
    func validDouble() -> Bool
    {
        let regex = "^\\d+(\\.\\d+)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self.trim())
    }
    
    func validURL() -> Bool
    {
        let regex = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self.trim())
    }
    
    
    
    
    func localURL() -> Bool
    {
        return !self.serverURL()
    }
    
    func serverURL() -> Bool
    {
        return !(self.index(of: "http:") == NSNotFound && self.index(of: "https:") == NSNotFound)
    }
    
    func URL() -> Foundation.URL? {
        if self.serverURL() {
            return Foundation.URL(string: self)
        } else {
            return Foundation.URL(fileURLWithPath: self)
        }
    }
    
    
    
    
    func index(of string: String) -> Int
    {
        return (self as NSString).range(of: string).location
    }
    
    func bundlePath() -> String?
    {
        return self.bundlePath(type: nil)
    }
    
    func bundlePath(type t:String?) -> String?
    {
        return Bundle.main.path(forResource: self, ofType: t)!
    }
    
    func homeDirPath() -> String
    {
        return NSHomeDirectory()
    }
    
    func documentDirPath() -> String?
    {
        return self.homeDirPath()+"/Documents"
    }
    
    func libraryDirPath() -> String?
    {
        return self.homeDirPath()+"/Library"
    }
    
    func cacheDirPath() -> String?
    {
        return self.homeDirPath()+"/Caches"
    }
    
    
    
    
    func truncate(by ellipsis:String, width:CGFloat, font:UIFont) -> String
    {
        if ((self as NSString).size(withAttributes: [NSAttributedStringKey.font:font]).width < width) {
            return self
        }
        
        var width = width
        let truncatedString = NSMutableString(string: "\(self)\(ellipsis)")
        
        width -= (ellipsis as NSString).size(withAttributes: [NSAttributedStringKey.font:font]).width
        
        var range = truncatedString.range(of: ellipsis)
        range.length = 1
        
        while (truncatedString.size(withAttributes: [NSAttributedStringKey.font:font]).width > width && range.location > 0)
        {
            range.location -= 1
            truncatedString.deleteCharacters(in: range)
        }
        
        return truncatedString as String
    }
    
}

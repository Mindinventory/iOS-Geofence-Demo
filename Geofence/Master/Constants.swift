//
//  Constants.swift
//  DemoSwift
//
//  Created by mac-0007 on 15/09/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

//func print(_ items: Any..., separator: String = " ", terminator: String = "\n")
//{
//   
//}


let CURRENT_DEVICE      = UIDevice.current

let CScreen             = UIScreen.main

let CScreenBounds       = CScreen.bounds

let CScreenHeight       = CScreenBounds.size.height

let CScreenWidth        = CScreenBounds.size.width

let CScreenCenterX      = CScreenWidth / 2.0

let CScreenCenterY      = CScreenHeight / 2.0

let CScreenCenter       = CGPoint(x: CScreenCenterX, y: CScreenCenterY)

let CBundle             = Bundle.main

let CUserDefaults       = UserDefaults.standard

let CSharedApplication  = UIApplication.shared

let appDelegate         = CSharedApplication.delegate as! AppDelegate

let UserdefaultsKey     =  "user_auth_token"


let GCDMainThread                   = DispatchQueue.main

let GCDBackgroundThread             = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)

let GCDBackgroundThreadLowPriority  = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)

let GCDBackgroundThreadHighPriority = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)





let iOS_NAME    = UIDevice.current.systemName

let iOS_VERSION = UIDevice.current.systemVersion
//let IS_iOS11_OR_LATER   = Double(iOS_VERSION) >= 11

//let IS_iOS10            = Int(Double(iOS_VERSION)!) == 10
//let IS_iOS10_OR_LATER   = Double(iOS_VERSION) >= 10
//
//let IS_iOS9             = Int(Double(iOS_VERSION)!) == 9
//let IS_iOS9_OR_LATER    = Double(iOS_VERSION) >= 9

//let IS_iOS8             = Int(Double(iOS_VERSION)!) == 8
//let IS_iOS8_OR_LATER    = Double(iOS_VERSION) >= 8
//
//let IS_iOS7             = Int(Double(iOS_VERSION)!) == 7
//let IS_iOS7_OR_LATER    = Double(iOS_VERSION) >= 7
//
//let IS_iOS6             = Int(Double(iOS_VERSION)!) == 6
//let IS_iOS6_OR_LATER    = Double(iOS_VERSION) >= 6


let DEVICE_NAME     = CURRENT_DEVICE.name

let DEVICE_MODEL    = CURRENT_DEVICE.model

let IS_SIMULATOR    = (TARGET_IPHONE_SIMULATOR == 1)

let IS_IPHONE       = DEVICE_MODEL.range(of: "iPhone") != nil

let IS_IPOD         = DEVICE_MODEL.range(of: "iPod") != nil

let IS_IPAD         = DEVICE_MODEL.range(of: "iPad") != nil


let IS_IPHONE_4     = IS_IPHONE && CScreenHeight == 480
let IS_IPHONE_5     = IS_IPHONE && CScreenHeight == 568
let IS_IPHONE_6     = IS_IPHONE && CScreenHeight == 667
let IS_IPHONE_6P    = IS_IPHONE && CScreenHeight == 736


let IS_IPAD_MINI    = IS_IPAD && CScreenHeight == 512
let IS_IPAD_MINI2   = IS_IPAD && CScreenHeight == 512
let IS_IPAD_AIR     = IS_IPAD && CScreenHeight == 1024
let IS_IPAD_PRO     = IS_IPAD && CScreenHeight == 1366

let CBundleID               = CBundle.bundleIdentifier
let CBundleInfo             = CBundle.infoDictionary
let CAppVersion             = CBundleInfo!["CFBundleShortVersionString"]
let CAppBuild               = CBundleInfo!["CFBundleVersion"]
let CAppName                = CBundleInfo!["CFBundleVersion"]

let CCacheDirectory         = NSHomeDirectory() + "/Library/Caches"
let CDocumentDirectory      = NSHomeDirectory() + "/Documents"
let CLimit                  = "20" as AnyObject

func IS_IPHONE_SIMULATOR() -> Bool
{
    #if (arch(i386) || arch(x86_64))
        return true
    #else
        return false
    #endif
    
}

func SYSTEM_VERSION_LESS_THAN(v: String) -> Any {
    return ((UIDevice.current.systemVersion.compare(v, options: .numeric, range: nil, locale: .current)) == .orderedAscending)
}

func CViewX(_ view:UIView) -> CGFloat {
    return view.frame.origin.x
}

func CViewY(_ view:UIView) -> CGFloat {
    return view.frame.origin.y
}

func CViewWidth(_ view:UIView) -> CGFloat {
    return view.frame.size.width
}

func CViewHeight(_ view:UIView) -> CGFloat {
    return view.frame.size.height
}

func CViewCenter(_ view:UIView) -> CGPoint {
    return view.center
}

func CViewCenterX(_ view:UIView) -> CGFloat {
    return CViewCenter(view).x
}

func CViewCenterY(_ view:UIView) -> CGFloat {
    return CViewCenter(view).y
}





func CViewSetX(_ view:UIView, x:CGFloat) -> Void {
    view.frame = CGRect(x: x, y: CViewY(view), width: CViewWidth(view), height: CViewHeight(view))
}

func CViewSetY(_ view:UIView, y:CGFloat) -> Void {
    view.frame = CGRect(x: CViewX(view), y: y, width: CViewWidth(view), height: CViewHeight(view))
}

func CViewSetWidth(_ view:UIView, width:CGFloat) -> Void {
    view.frame = CGRect(x: CViewX(view), y: CViewY(view), width: width, height: CViewHeight(view))
}

func CViewSetHeight(_ view:UIView, height:CGFloat) -> Void {
    view.frame = CGRect(x: CViewX(view), y: CViewY(view), width: CViewWidth(view), height: height)
}

func CViewSetOrigin(_ view:UIView, x:CGFloat, y:CGFloat) -> Void {
    view.frame = CGRect(x: x, y: y, width: CViewWidth(view), height: CViewHeight(view))
}

func CViewSetSize(_ view:UIView, width:CGFloat, height:CGFloat) -> Void {
    view.frame = CGRect(x: CViewX(view), y: CViewY(view), width: width, height: height)
}

func CViewSetFrame(_ view:UIView, x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) -> Void {
    view.frame = CGRect(x: x, y: y, width: width, height: height)
}

func CViewSetCenter(_ view:UIView, x:CGFloat, y:CGFloat) -> Void {
    view.center = CGPoint(x: x, y: y)
}

func CViewSetCenterX(_ view:UIView, x:CGFloat) -> Void {
    view.center = CGPoint(x: x, y: CViewCenterY(view))
}

func CViewSetCenterY(_ view:UIView, y:CGFloat) -> Void {
    view.center = CGPoint(x: CViewCenterX(view), y: y)
}




func CRectX(_ frame:CGRect) -> CGFloat {
    return frame.origin.x
}

func CRectY(_ frame:CGRect) -> CGFloat {
    return frame.origin.y
}

func CRectWidth(_ frame:CGRect) -> CGFloat {
    return frame.size.width
}

func CRectHeight(_ frame:CGRect) -> CGFloat {
    return frame.size.height
}


func CRGB(r red:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

func CRGBA(r red:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}












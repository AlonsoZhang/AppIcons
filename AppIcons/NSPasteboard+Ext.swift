//
//  NSPasteboard+Ext.swift
//  AppIcons
//
//  Created by Alonso on 2018/1/9.
//  Copyright © 2018年 Alonso. All rights reserved.
//

import Cocoa

extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
    } ()
}

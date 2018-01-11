//
//  DragImageView.swift
//  AppIcons
//
//  Created by Alonso on 2018/1/3.
//  Copyright © 2018年 Alonso. All rights reserved.
//

import Cocoa

protocol DragImageZoneDelegate: class {
    func didFinishDragWithFile(_ files:Array<Any>)
}

class DragImageView: NSImageView {
    weak var delegate: DragImageZoneDelegate?
    var highlight = false
    
    func dropAreaFadeIn() {
        self.alphaValue = 1.0
    }
    
    func dropAreaFadeOut() {
        self.alphaValue = 0.3
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if highlight {
            NSColor.blue.set()
            NSBezierPath.defaultLineWidth = 10
            NSBezierPath.stroke(dirtyRect)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if (highlight == false) {
            highlight = true
            self.needsDisplay = true
            self.dropAreaFadeOut()
        }
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        let dragTypes = pboard.types! as NSArray
        if dragTypes.contains(NSPasteboard.PasteboardType.fileURL) {
            if sourceDragMask.contains([.link]) {
                return .link
            }
            if sourceDragMask.contains([.copy]) {
                return .copy
            }
        }
        return .generic
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return self.draggingEntered(sender)
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        highlight = false
        self.dropAreaFadeIn()
        self.needsDisplay = true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo)-> Bool {
        let pboard = sender.draggingPasteboard()
        let dragTypes = pboard.types! as NSArray
        if dragTypes.contains(NSPasteboard.PasteboardType.fileURL) {
            let files = (pboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType"))) as! Array<String>
            let numberOfFiles = files.count
            if numberOfFiles > 0 {
                if let delegate = self.delegate {
                    highlight = false
                    self.needsDisplay = true
                    self.dropAreaFadeIn()
                    delegate.didFinishDragWithFile(files)
                }
            }
        }
        return true
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
}

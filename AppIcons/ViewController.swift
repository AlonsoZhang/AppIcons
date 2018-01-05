//
//  ViewController.swift
//  AppIcons
//
//  Created by Alonso on 2018/1/3.
//  Copyright © 2018年 Alonso. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var dragView: DragImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dragView.delegate = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: DragImageZoneDelegate {
    func didFinishDragWithFile(_ files: Array<Any>) {
        if files.count > 1 {
            //folderPath.textColor = NSColor.red
            print("Please drag one folder once !!!")
            //folderPath.stringValue = "Please drag one folder once !!!"
        }else{
            //folderPath.textColor = NSColor.blue
            let path = files[0]
            print("\(path)")
            //folderPath.stringValue = "\(path)"
        }
    }
}


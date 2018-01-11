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
    var largeImagePath: String?
    var exportPath: String?
    var imageScaleConfig: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dragView.delegate = self
        let filePath = Bundle.main.path(forResource: "imageSize", ofType: "plist")
        let dataMap = NSDictionary(contentsOfFile: filePath!)
        self.imageScaleConfig = dataMap
        self.exportPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory,.userDomainMask,true)[0]
    }
    
    //根据1024*1024大图生成不同平台图标
    func makeAppIconWithType(type:String) {
        let imageFolerPath = (self.exportPath! as NSString).appendingPathComponent("AppIcon.appiconset")
        let fm  = FileManager()
        let success = fm.createPathIfNeded(path: imageFolerPath)
        if !success {
            return
        }
        //清除目录,防止以前存在垃圾文件
        fm.clearAllFilesAtPath(path: imageFolerPath)
        let largeImage = NSImage(contentsOfFile: self.largeImagePath!)
        let configs = self.platAssetsConfig(type:type)
        for config in configs {
            let imageSizeConfig = config["imageSizeConfig"] as? Dictionary<String,Any>
            let imageFlag = config["imageFlag"]!
            let keys = imageSizeConfig?.keys
            
            for key in keys! {
                let scales = imageSizeConfig?[key] as! [NSNumber]
                let size = key
                for scaleNum in scales {
                    let scale = scaleNum.intValue
                    let retion = scale
                    let long = Double(size)! * Double(retion)
                    let imageSize = NSSize(width: long, height: long)
                    //按新的尺寸生成图像
                    let image = largeImage?.reSize(size: imageSize)
                    var imageName: String
                    if retion == 1 {
                        imageName = "icon_\(imageFlag)_\(size).png"
                    }
                    else {
                        imageName = "icon_\(imageFlag)_\(size)@\(retion)x.png"
                    }
                    let imagePath = (imageFolerPath as NSString).appendingPathComponent(imageName)
                    //保存图像
                    image?.saveAtPath(path: imagePath)
                }
            }
        }
    }
    
    //根据Plist生成不同平台的JSON格式文件
    func makeJSONFileWithType(type:String) {
        let configs = self.platAssetsConfig(type:type)
        var images = [[String:Any]]()
        for config in configs {
            let imageSizeConfig = config["imageSizeConfig"] as? Dictionary<String,Any>
            let imageFlag = config["imageFlag"]!
            let keys = imageSizeConfig?.keys
            for key in keys! {
                let scales = imageSizeConfig?[key] as! [NSNumber]
                let keynumber = Double(key)!
                var size = "\(keynumber)"
                if Double(Int(keynumber)) == keynumber{
                    size = "\(Int(keynumber))"
                }
                for scaleNum in scales {
                    let scale = scaleNum.intValue
                    let retion = scale
                    var imageName: String
                    if retion == 1 {
                        imageName = "icon_\(imageFlag)_\(size).png"
                    }
                    else {
                        imageName = "icon_\(imageFlag)_\(size)@\(retion)x.png"
                    }
                    var imageInfo = [String:Any]()
                    imageInfo["size"] = "\(size)x\(size)"
                    imageInfo["idiom"] = imageFlag
                    imageInfo["filename"] = imageName
                    imageInfo["scale"] = "\(retion)x"
                    images.append(imageInfo)
                }
            }
        }
        var jsonMap = [String:Any]()
        jsonMap["info"] = ["version":1,"author":"xcode"]
        jsonMap["images"] = images
        let data = try? JSONSerialization.data(withJSONObject: jsonMap, options: [.prettyPrinted])
        let imageFolerPath = (self.exportPath! as NSString).appendingPathComponent("AppIcon.appiconset")
        let isOK = FileManager().createFileIfNeeded(filePath: imageFolerPath)
        if !isOK {
            return
        }
        let jsonurl = URL(fileURLWithPath: imageFolerPath).appendingPathComponent("Contents.json")
        do {
            try data?.write(to: jsonurl)
        } catch  {
            print("error")
        }
    }
    
    //获取不同平台的图片配置
    func platAssetsConfig(type:String) ->[Dictionary<String,Any>] {
        var configs: [Dictionary<String,Any>]
        if type == "iOS" {
            let iPhoneConfig = self.imageScaleConfig?["iphone"]
            let iPadConfig = self.imageScaleConfig?["ipad"]
            configs = [[
                "imageSizeConfig":iPhoneConfig!,
                "imageFlag":"iphone"
                ],
                       ["imageSizeConfig":iPadConfig!,
                        "imageFlag":"ipad"
                ]
            ]
        }else if type == "MacOS" {
            let config = self.imageScaleConfig?["mac"]
            configs = [[
                "imageSizeConfig":config!,
                "imageFlag":"mac"
                ]]
        }else{
            configs = [[
                "imageSizeConfig":"error",
                "imageFlag":"error"
                ]]
        }
        return configs
    }
}

extension ViewController: DragImageZoneDelegate {
    func didFinishDragWithFile(_ files: Array<Any>) {
        var message = ""
        if files.count > 1 {
            message = "Please drag one file once!!!"
        }else{
            let path = files[0]
            self.largeImagePath = path as? String
            if self.largeImagePath == nil {
                message = "ImagePath is nil!!!"
            }else{
                let patharr: Array = self.largeImagePath!.components(separatedBy: "/")
                if patharr.count > 0 {
                    if patharr.last!.contains(".png"){
                        self.showalert()
                    }else{
                        message = "Icon image format is wrong!!!"
                    }
                }else{
                    message = "ImagePath is wrong!!!"
                }
            }
        }
        if message.count > 0 {
            showalert(error: message)
        }
    }
    
    func showalert() {
        let alert = NSAlert()
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "iOS")
        alert.addButton(withTitle: "MacOS")
        alert.messageText = "Please Choose your device"
        alert.informativeText = "App will close and create AppIcon.appiconset on your desktop"
        alert.alertStyle = .informational
        alert .beginSheetModal(for: self.view.window!, completionHandler: { returnCode in
            if returnCode.rawValue == 1001{
                self.makeAppIconWithType(type:"iOS")
                self.makeJSONFileWithType(type:"iOS")
                NSApp.terminate(nil)
            }else if returnCode.rawValue == 1002{
                self.makeAppIconWithType(type:"MacOS")
                self.makeJSONFileWithType(type:"MacOS")
                NSApp.terminate(nil)
            }
        })
    }
    
    func showalert(error:String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = error
        alert.alertStyle = .warning
        alert .beginSheetModal(for: self.view.window!, completionHandler: { returnCode in
        })
    }
}


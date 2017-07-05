//
//  ViewController.swift
//  SimilarImageForiOS
//
//  Created by famulei on 03/07/2017.
//  Copyright © 2017 famulei. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSFetchedResultsControllerDelegate {
    
    var images: Dictionary<String, Image> = [String:Image]();
    
    var selectedPath: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet var openFolder: NSButton!
    @IBAction func openFolderAction(_ sender: NSButton) {
        let panel = NSOpenPanel()
        panel.message = "选择文件夹";
        panel.canChooseDirectories = true;
        panel.canChooseFiles = false;
        panel.beginSheetModal(for: self.view.window!) { (result) in
            if result == NSModalResponseOK {
                self.prepareImages(url: panel.urls.first!)
            }
        }
    }
    
    
    func prepareImages(url: URL) {
        selectedPath = url.path;
        getImages(url: url);
    }
    
    
    
    /// 获取url 下的所有图片
    ///
    /// - Parameter url: 图片地址
    func getImages(url: URL) {
        if let paths = FileManager.default.subpaths(atPath: url.path) {
            for filePath in paths {
                extraImagePath(path: filePath)
            }
        }
    }
    
    
    func extraImagePath(path: String) {
        if path.hasSuffix(".png") {
           let imageInfo = path.components(separatedBy: "@")
            var key = "";
            if imageInfo.count == 1 {
                // 没有尺寸的图片
                key = imageInfo.first!.components(separatedBy: ".png").first!;
            } else {
                key = imageInfo.first!;
            }
            
            if images[key] == nil {
                var image = Image()
                image.imageUrl = key;
                image.imageArray.append(self.selectedPath! + "/" + path);
                images[key] = image;
            } else {
                images[key]?.imageArray.append(self.selectedPath! + "/" + path);
            }
        }
        
    }
    
    
   
}



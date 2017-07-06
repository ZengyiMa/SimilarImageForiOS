//
//  ViewController.swift
//  SimilarImageForiOS
//
//  Created by famulei on 03/07/2017.
//  Copyright © 2017 famulei. All rights reserved.
//

import Cocoa
import CoreGraphics

class ViewController: NSViewController, NSFetchedResultsControllerDelegate {
    
    var images: Dictionary<String, Image> = [String:Image]();
    
    var selectedPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        let image = images.first?.value
        let originImage =  NSImage(contentsOfFile: (image?.imageArray.last)!);
        
        var smallImage = resize(forImage: originImage!, size: CGSize(width: 8, height: 8));
        
        covertToGrey(forImage: smallImage)
        
    }
    
    

    
    func resize(forImage image: NSImage, size: CGSize) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus();
        let ctx = NSGraphicsContext.current();
        ctx?.imageInterpolation = .high;
        image.draw(in: NSRect(x: 0, y: 0, width: size.width, height: size.height));
        img.unlockFocus();
        return img;
    }
    
    func covertToGrey(forImage image: NSImage) -> [[Float]] {
        
        var imageRect = NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        var bitmap = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!)
        
        var greyArray: [[Float]] = []
        
        for  x in 0..<Int(image.size.width) {
            for  y in 0..<Int(image.size.height) {
                let red = (bitmap.colorAt(x: x, y: y)?.redComponent)! * 255;
                let green = (bitmap.colorAt(x: x, y: y)?.greenComponent)! * 255;
                let blue = (bitmap.colorAt(x: x, y: y)?.blueComponent)! * 255;
                // 灰度公式
                var greyValue = red * 299/1000 + green * 587/1000 + blue * 114 / 1000;
                greyArray[x][y] = Float(greyValue);
            }
        }
        
        return greyArray;
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



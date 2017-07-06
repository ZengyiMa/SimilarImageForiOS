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
        for (key, image) in images {
            let originImage =  NSImage(contentsOfFile: (image.imageArray.last!));
            let hashMeta = covertToGrey(forImage: resize(forImage: originImage!, size: CGSize(width: 8, height: 8)))
            images[key]?.imageHash = hashMeta.2.map { (i) -> String in
                String(i)
                }.joined();
        }
        
        var sameImages: Dictionary<String, [Image]> = [:]
        for (_, image) in images {
            var isSame = false;
            for (imgHash, images) in sameImages {
                if isSameImage(firstHash: image.imageHash, secondHash: imgHash) {
                    // 是同一个图片
                    sameImages[imgHash]?.append(image);
                    isSame = true;
                    break;
                }
            }
            if isSame == false {
                // 没有任何相同的，自己创建一组
                sameImages[image.imageHash] = [image];
            }
        }
        
        // 输出结果
       let dict = sameImages.filter {
            return $1.count > 1;
        }
        
        _ = dict.map { (key, value) -> [Image] in
            print("======== 相似的图片 指纹(\(key)) =========")
            _ = value.map({ (image: Image) -> Image in
                print("   图片地址=== \(image.imageArray.first!) 指纹(\(image.imageHash))");
                return image
            })
            

            return value;
        }
    }

    func resize(forImage image: NSImage, size: CGSize) -> NSImage {
        
        let img = NSImage(size: CGSize(width: size.width / 2, height: size.height / 2))
        img.lockFocus();
        let ctx = NSGraphicsContext.current();
        ctx?.imageInterpolation = .high;
        image.draw(in: NSRect(x: 0, y: 0, width: size.width / 2, height: size.height / 2));
        img.unlockFocus();
        return img;
    }
    
    func covertToGrey(forImage image: NSImage) -> ([[Float]], Float, [Int]) {
        
        var imageRect = NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let bitmap = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)!)
        var greyArray: [[Float]] = [];
        var totalGrey: Float = 0;
        for  x in 0..<Int(bitmap.pixelsWide) {
            greyArray.append([]);
            for  y in 0..<Int(bitmap.pixelsHigh) {
                let red = (bitmap.colorAt(x: x, y: y)?.redComponent)! * 255;
                let green = (bitmap.colorAt(x: x, y: y)?.greenComponent)! * 255;
                let blue = (bitmap.colorAt(x: x, y: y)?.blueComponent)! * 255;
                let greyValue = red * (299/1000) + green * (587/1000) + blue * (114 / 1000);
                totalGrey += Float(greyValue);
                greyArray[x].append(Float(greyValue))
            }
        }
        
        let avgGrey = totalGrey / Float(bitmap.pixelsWide * bitmap.pixelsHigh)
        var imgHash: [Int] = [];
        for  x in 0..<Int(greyArray.count) {
            for  y in 0..<Int(greyArray[x].count) {
                if greyArray[x][y] > avgGrey {
                    imgHash.append(1);
                } else {
                    imgHash.append(0);
                }
            }
        }
        return (pixelsGrey: greyArray, avgGrey: avgGrey, imgHash: imgHash);
    }
    
    func isSameImage(firstHash hash1:String, secondHash hash2:String) -> Bool {
        
        if hash1.characters.count != hash2.characters.count {
            return false;
        }
        
        let thredHold: Int = 5;
        var count: Int = 0;
        for index in hash1.characters.indices {
            if hash1[index] != hash2[index] {
                count += 1;
                if count >= thredHold {
                    break;
                }
            }
        }
        if count >= thredHold {
            return false
        } else {
            return true
        }
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



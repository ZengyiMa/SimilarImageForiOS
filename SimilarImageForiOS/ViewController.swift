//
//  ViewController.swift
//  SimilarImageForiOS
//
//  Created by famulei on 03/07/2017.
//  Copyright © 2017 famulei. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSFetchedResultsControllerDelegate {
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
                print("打开文件夹\(panel.urls)");
            }
        }
    }
}


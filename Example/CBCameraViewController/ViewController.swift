//
//  ViewController.swift
//  CBCameraViewController
//
//  Created by Cathy Oun on 09/02/2016.
//  Copyright (c) 2016 Cathy Oun. All rights reserved.
//

import UIKit
import CBCameraViewController
import AssetsLibrary
import SnapKit

class ViewController: UIViewController, CBCameraViewControllerDelegate {

    let cameraVC = CBCameraViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraVC.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        presentViewController(cameraVC, animated: false, completion: nil)
    }
    
    func cameraViewController(cameraViewController: CBCameraViewController, didTakePhoto asset: UIImage) {
        // save photo
        cameraViewController.cameraOutputQuality = CBCameraOutputQuality.Medium
        print("Photo captured!")
//        let data = UIImagePNGRepresentation(asset)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(asset.CGImage, orientation: ALAssetOrientation(rawValue: asset.imageOrientation.rawValue)!,
                                                       completionBlock:{ (path:NSURL!, error:NSError!) -> Void in
                                                        print("\(path)")  //Here you will get your path
        })
    }
    
    func cameraViewController(cameraViewController: CBCameraViewController, didRecoredVideo assetURL: NSURL) {
        // save video
        let outputURL = FileUtils.createCleanFileURL(fileName: "outputVideo.mp4")

        let data = NSData(contentsOfURL: assetURL)
        do {
            try data?.writeToURL(outputURL, options: NSDataWritingOptions.DataWritingFileProtectionNone)
        } catch let outError {
            print(outError)
        }
    }

}


class FileUtils: NSObject {
    static func createCleanFileURL(fileName fileName:String) -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        guard let documentDirectory: NSURL = urls.first else {
            fatalError("documentDir Error")
        }
        let videoOutputURL = documentDirectory.URLByAppendingPathComponent(fileName)
        
        if NSFileManager.defaultManager().fileExistsAtPath(videoOutputURL.path!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(videoOutputURL.path!)
            } catch {
                fatalError("Unable to delete file: \(error) : \(#function).")
            }
        }
        return videoOutputURL
    }
}


//
//  ViewController.swift
//  CBCameraViewController
//
//  Created by Cathy Oun on 09/02/2016.
//  Copyright (c) 2016 Cathy Oun. All rights reserved.
//

import UIKit
import CBCameraViewController
import SnapKit

class ViewController: UIViewController, CBCameraViewControllerDelegate {

    let cameraVC = CBCameraViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraVC.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        present(cameraVC, animated: false, completion: nil)
    }
    
    func cameraViewController(cameraViewController: CBCameraViewController, didTakePhoto asset: UIImage) {
        // save photo
        print("Photo captured!")
        UIImageWriteToSavedPhotosAlbum(asset, nil, nil, nil)
    }
    
    func cameraViewController(cameraViewController: CBCameraViewController, didRecoredVideo assetURL: NSURL) {
        // save video
        let outputURL = FileUtils.createCleanFileURL("outputVideo.mp4")

        let data = NSData(contentsOf: assetURL as URL)
        do {
            try data?.write(to: outputURL as URL, options: NSData.WritingOptions.noFileProtection)
        } catch let outError {
            print(outError)
        }
    }

}


class FileUtils: NSObject {
    static func createCleanFileURL(_ fileName:String) -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory: NSURL = urls.first as NSURL? else {
            fatalError("documentDir Error")
        }
        let videoOutputURL = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: videoOutputURL!.path) {
            do {
                try FileManager.default.removeItem(atPath: videoOutputURL!.path)
            } catch {
                fatalError("Unable to delete file: \(error) : \(#function).")
            }
        }
        return videoOutputURL!
    }
}


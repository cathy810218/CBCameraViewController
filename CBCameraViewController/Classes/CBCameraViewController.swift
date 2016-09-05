//
//  CBCameraViewController.swift
//  Pods
//
//  Created by Cathy Oun on 9/2/16.
//
//

import UIKit
import SnapKit
import CameraManager
import Photos

public class CBCameraViewController: UIViewController {
    public weak var delegate: CBCameraViewControllerDelegate?
    
    public var captureView   = UIImageView()
    public var captureButton = UIButton()
    public var videoButton   = UIButton()
    public var flashButton   = UIButton()
    public var outputURL = NSURL()
    var outputImage: UIImage?
    
    private let cameraManager = CameraManager()
    private var isRecording = false

    //MARK: View lifecycle
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(captureView)
        captureView.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        view.addSubview(captureButton)
        captureButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.bottom.centerX.equalTo(view)
        }
        captureButton.backgroundColor = UIColor.redColor()
        captureButton.addTarget(self, action: #selector(captureImage), forControlEvents: .TouchUpInside)
    
        view.addSubview(videoButton)
        videoButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.bottom.equalTo(view)
            make.right.equalTo(captureButton.snp_left).offset(-15)
        }
        videoButton.setTitle("Video", forState: .Normal)
        videoButton.addTarget(self, action: #selector(recordVideo), forControlEvents: .TouchUpInside)
        
        view.addSubview(flashButton)
        flashButton.snp_makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.top.right.equalTo(view)
        }
        flashButton.backgroundColor = UIColor.yellowColor()
        flashButton.addTarget(self, action: #selector(changeFlashMode), forControlEvents: .TouchUpInside)
    }

    @objc private func captureImage() {
        cameraManager.cameraOutputMode = .StillImage
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            self.outputImage = image
            self.delegate?.cameraViewController?(self, didTakePhoto: image!)
        })
    }
    
    @objc private func recordVideo() {
        cameraManager.cameraOutputMode = .VideoWithMic
        if isRecording {
            videoButton.setTitle("Video", forState: .Normal)
            stopRecording()
            isRecording = false
        } else {
            cameraManager.startRecordingVideo()
            videoButton.setTitle("Stop", forState: .Normal)
            isRecording = true
        }

    }
    
    private func stopRecording() {
        cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
            print("in here")
            do {
                self.outputURL = FileUtils.createCleanFileURL(fileName: "outputVideo.mp4")
                print("video url: \(videoURL)")
                print("output url: \(self.outputURL)")
                let data = NSData(contentsOfURL: videoURL!)
                try data?.writeToURL(self.outputURL, options: NSDataWritingOptions.DataWritingFileProtectionNone)
                self.delegate?.cameraViewController?(self, didRecoredVideo: self.outputURL)
            } catch let outError {
                print(outError)
            }
        })
    }
    

    @objc private func changeFlashMode() {
        cameraManager.changeFlashMode()
        print(cameraManager.flashMode.rawValue)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraManager.addPreviewLayerToView(captureView)
    }
}

@objc public protocol CBCameraViewControllerDelegate: class {
    optional func cameraViewController(cameraViewController: CBCameraViewController, didTakePhoto asset: UIImage)
    optional func cameraViewController(cameraViewController: CBCameraViewController, didRecoredVideo assetURL: NSURL)
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


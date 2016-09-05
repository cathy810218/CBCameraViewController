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
import AVFoundation
import Photos

public enum CBCameraOutputQuality: Int {
    case Low, Medium, High
}

public class CBCameraViewController: UIViewController {
    public weak var delegate: CBCameraViewControllerDelegate?
    
    public var captureView   = UIImageView()
    public var captureButton = UIButton()
    public var videoButton   = UIButton()
    public var flashButton   = UIButton()
    public var outputURL = NSURL()

    private let cameraManager = CameraManager()
    private var isRecording = false
    
    public var cameraOutputQuality: CBCameraOutputQuality = .Medium {
        didSet {
            cameraManager.cameraOutputQuality =
                CameraOutputQuality(rawValue: cameraOutputQuality.rawValue)!
        }
    }
    
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
            make.height.equalTo(50)
            make.width.equalTo(70)
            make.bottom.centerX.equalTo(view)
        }
        captureButton.setTitle("Capture", forState: .Normal)
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
        cameraManager.writeFilesToPhoneLibrary = false

        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            //TODO: Customize image size
            if let image = image {
                let scaledImage = self.resizeImageToFitFullScreen(image)
                self.delegate?.cameraViewController?(self, didTakePhoto: scaledImage)

            }
        })
    }
    private func resizeImageToFitFullScreen(image: UIImage) -> UIImage{
        let newHeight = UIScreen.mainScreen().bounds.height
        let newWidth = UIScreen.mainScreen().bounds.width
        
        let aspectHeight = newHeight / image.size.height
        let aspectWidth = newWidth / image.size.width
        let aspectRatio = max(aspectWidth, aspectHeight)
        
        var scaledImageRect = CGRectZero
        scaledImageRect.size.height = image.size.height * aspectRatio
        scaledImageRect.size.width = image.size.width * aspectRatio
        scaledImageRect.origin.x = (newWidth - scaledImageRect.size.width) / 2
        scaledImageRect.origin.y = (newHeight - scaledImageRect.size.height) / 2

        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(scaledImageRect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
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
                self.delegate?.cameraViewController?(self, didRecoredVideo: videoURL!)
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

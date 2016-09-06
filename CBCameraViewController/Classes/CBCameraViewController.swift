//
//  CBCameraViewController.swift
//  Pods
//
//  Created by Cathy Oun on 9/2/16.
//
//

import UIKit
import SnapKit
import AVFoundation
import Photos

extension UIImage {
    static func bundleImage(named named: String) -> UIImage {
        let bundle = NSBundle(forClass: CBCameraViewController.self)
        return UIImage(named: named, inBundle: bundle, compatibleWithTraitCollection: nil)!
    }
}

public enum CameraState {
    case Ready, AccessDenied, NoDeviceFound, NotDetermined
}

public enum CameraDevice {
    case Front, Back
}

public enum CameraFlashMode: Int {
    case Off, On, Auto
}

public enum CameraOutputMode {
    case StillImage, VideoWithMic, VideoOnly
}

public enum CameraOutputQuality: Int {
    case Low, Medium, High
}


public class CBCameraViewController: UIViewController {
    public weak var delegate: CBCameraViewControllerDelegate?
    
    // UI elements
    public var capturePreview   = UIImageView()
    public var captureButton = UIButton()
    public var cameraDeviceButton = UIButton()
    public var flashButton = UIButton()
    
    //MARK: - Public properties
    
    /// Capture session to customize camera
    public var captureSession = AVCaptureSession()

    /// Property to determine if the manager should show the camera permission popup immediatly when it's needed or you want to show it manually. Default value is true. Be carful cause using the camera requires permission, if you set this value to false and don't ask manually you won't be able to use the camera.
    public var showAccessPermissionPopupAutomatically = true
    
    /// Property to determine if manager should write the resources to the phone library. Default value is true.
    public var writeFilesToPhoneLibrary = false

    
    /// The Bool property to determine if the camera is ready to use.
//    public var cameraIsReady: Bool {
//        get {
//            return cameraIsSetup
//        }
//    }
    public var flashMode = CameraFlashMode.Off {
        didSet {
//            if cameraIsSetup {
                if flashMode != oldValue {
                    _updateFlashMode(flashMode)
                }
//            }
        }
    }
    
    /// The Bool property to determine if current device has front camera.
    public var hasFrontCamera: Bool = {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for  device in devices  {
            let captureDevice = device as! AVCaptureDevice
            if (captureDevice.position == .Front) {
                return true
            }
        }
        return false
    }()

    public func changeFlashMode() -> CameraFlashMode {
        flashMode = CameraFlashMode(rawValue: (flashMode.rawValue+1)%3)!
        return flashMode
    }
    
    /// Property to change camera device between front and back.
    public var cameraDevice = CameraDevice.Back {
        didSet {
//            if cameraIsSetup {
            if cameraDevice != oldValue {
                _updateCameraDevice(cameraDevice)
//                    _setupMaxZoomScale()
//                    _zoom(0)
            }
//            }
        }
    }
    
    
    /// Property to change camera output quality.
    public var cameraOutputQuality = CameraOutputQuality.High {
        didSet {
//            if cameraIsSetup {
//                if cameraOutputQuality != oldValue {
//                    _updateCameraQualityMode(cameraOutputQuality)
//                }
//            }
        }
    }

    /// Property to change camera output.
    public var cameraOutputMode = CameraOutputMode.StillImage {
        didSet {
//            if cameraIsSetup {
//                if cameraOutputMode != oldValue {
//                    _setupOutputMode(cameraOutputMode, oldCameraOutputMode: oldValue)
//                }
//                _setupMaxZoomScale()
//                _zoom(0)
//            }
        }
    }
    
    private var sessionQueue: dispatch_queue_t = dispatch_queue_create("CameraSessionQueue", DISPATCH_QUEUE_SERIAL)

    private lazy var frontCameraDevice: AVCaptureDevice? = {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        return devices.filter{$0.position == .Front}.first
    }()
    
    private lazy var backCameraDevice: AVCaptureDevice? = {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        return devices.filter{$0.position == .Back}.first
    }()
    
    private var stillImageOutput = AVCaptureStillImageOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

//    private var cameraIsSetup = false
    
    //MARK: View lifecycle
    public init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(capturePreview)
        capturePreview.snp_makeConstraints { (make) in
            make.edges.equalTo(view)
        }

        view.addSubview(captureButton)
        captureButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(80)
            make.bottom.centerX.equalTo(view)
        }
        captureButton.setImage(UIImage.bundleImage(named: "camera"), forState: .Normal)
        captureButton.addTarget(self, action: #selector(handleCapturePhoto), forControlEvents: .TouchUpInside)

        //
//        view.addSubview(videoButton)
//        videoButton.snp_makeConstraints { (make) in
//            make.width.height.equalTo(80)
//            make.bottom.equalTo(view)
//            make.right.equalTo(captureButton.snp_left).offset(-15)
//        }
//        videoButton.setImage(UIImage.bundleImage(named: "video"), forState: .Normal)
//        videoButton.addTarget(self, action: #selector(recordVideo), forControlEvents: .TouchUpInside)
//        
        view.addSubview(flashButton)
        flashButton.snp_makeConstraints { (make) in
            make.height.width.equalTo(35)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(view).offset(30)
        }
        flashButton.setImage(UIImage.bundleImage(named: "flash-off"), forState: .Normal)

        cameraDeviceButton.backgroundColor = UIColor.redColor()
        view.addSubview(cameraDeviceButton)
        cameraDeviceButton.snp_makeConstraints { (make) in
            make.top.equalTo(flashButton)
            make.height.width.equalTo(35)
            make.right.equalTo(flashButton.snp_left).offset(-15)
        }
        cameraDeviceButton.addTarget(self, action: #selector(handleSwitchCameraDevice), forControlEvents: .TouchUpInside)
        flashButton.addTarget(self, action: #selector(handleChangeFlashMode), forControlEvents: .TouchUpInside)
//    }
    

    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if captureDevice != nil {
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            } catch let outError {
                print(outError)
            }
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                previewLayer.bounds = view.bounds
                previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                capturePreview.layer.addSublayer(previewLayer)
                
            }
        }
    }
    
    //MARK: - Handler
    @objc private func handleCapturePhoto() {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataBuffer, error) in
                if error == nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                    let originalImage = UIImage(data: imageData)
                    let fullscreenImage = self.resizeImageToFitFullScreen(originalImage!)
                    self.delegate?.cameraViewController?(self, didTakePhoto: fullscreenImage)
                }
            })
        }
    }
    
    @objc private func handleSwitchCameraDevice() {
        if cameraDevice == .Back {
            cameraDevice = .Front
        } else {
            cameraDevice = .Back
        }
    }

    @objc private func handleChangeFlashMode() {
        changeFlashMode()
        
        switch flashMode.rawValue {
        case 0:
            flashButton.setImage(UIImage.bundleImage(named: "flash-off"), forState: .Normal)
        case 1:
            flashButton.setImage(UIImage.bundleImage(named: "flash-on"), forState: .Normal)
        case 2:
            flashButton.setImage(UIImage.bundleImage(named: "flash-auto"), forState: .Normal)
        default:
            break
        }
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
    
    private func _updateFlashMode(flashMode: CameraFlashMode) {
        captureSession.beginConfiguration()
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for  device in devices  {
            let captureDevice = device as! AVCaptureDevice
            if (captureDevice.position == AVCaptureDevicePosition.Back) {
                let avFlashMode = AVCaptureFlashMode(rawValue: flashMode.rawValue)
                if (captureDevice.isFlashModeSupported(avFlashMode!)) {
                    do {
                        try captureDevice.lockForConfiguration()
                    } catch {
                        return
                    }
                    captureDevice.flashMode = avFlashMode!
                    captureDevice.unlockForConfiguration()
                }
            }
        }
        captureSession.commitConfiguration()
    }
    
    private func _updateCameraDevice(deviceType: CameraDevice) {
            captureSession.beginConfiguration()
            let inputs = captureSession.inputs as! [AVCaptureInput]
            
            for input in inputs {
                if let deviceInput = input as? AVCaptureDeviceInput {
                    if deviceInput.device == backCameraDevice && cameraDevice == .Front {
                        captureSession.removeInput(deviceInput)
                        break;
                    } else if deviceInput.device == frontCameraDevice && cameraDevice == .Back {
                        captureSession.removeInput(deviceInput)
                        break;
                    }
                }
            }
            switch cameraDevice {
            case .Front:
                if hasFrontCamera {
                    if let validFrontDevice = _deviceInputFromDevice(frontCameraDevice) {
                        if !inputs.contains(validFrontDevice) {
                            captureSession.addInput(validFrontDevice)
                        }
                    }
                }
            case .Back:
                if let validBackDevice = _deviceInputFromDevice(backCameraDevice) {
                    if !inputs.contains(validBackDevice) {
                        captureSession.addInput(validBackDevice)
                    }
                }
            }
            captureSession.commitConfiguration()
        }

    private func _deviceInputFromDevice(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let outError {
//            _show(NSLocalizedString("Device setup error occured", comment:""), message: "\(outError)")
            return nil
        }
    }

}

@objc public protocol CBCameraViewControllerDelegate: class {
    optional func cameraViewController(cameraViewController: CBCameraViewController, didTakePhoto asset: UIImage)
    optional func cameraViewController(cameraViewController: CBCameraViewController, didRecoredVideo assetURL: NSURL)
}

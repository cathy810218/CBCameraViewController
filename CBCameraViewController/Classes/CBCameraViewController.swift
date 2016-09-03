//
//  CBCameraViewController.swift
//  Pods
//
//  Created by Cathy Oun on 9/2/16.
//
//

import UIKit
import SnapKit
import Photos

public class CBCameraViewController: UIViewController {
    public weak var delegate: CBCameraViewControllerDelegate?

    var captureView  = UIImageView()
    var bottomView   = UIView()
    var cameraButton = UIButton()
    var videoButton  = UIButton()
    
    //MARK: View lifecycle
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initBottomViewWithButtons()
        initCaptureView()
    }
    
    private func initBottomViewWithButtons() {
        bottomView.backgroundColor = UIColor.grayColor()
        view.addSubview(bottomView)
        bottomView.backgroundColor = UIColor.grayColor()
        bottomView.snp_makeConstraints { (make) in
            make.height.equalTo(66)
            make.width.bottom.left.equalTo(view)
        }
        
        bottomView.addSubview(cameraButton)
        bottomView.addSubview(videoButton)
        cameraButton.snp_makeConstraints { (make) in
            
        }
    }
    
    private func initCaptureView() {
        view.addSubview(captureView)
        captureView.snp_makeConstraints { (make) in
            make.left.right.equalTo(view)
        }
    }
}

@objc public protocol CBCameraViewControllerDelegate: class {
    optional func cameraViewController(cameraViewController: CBCameraViewController, didTakePhoto asset:PHObject)
    optional func cameraViewController(cameraViewController: CBCameraViewController, didRecoredVideo assets: PHObject)

}

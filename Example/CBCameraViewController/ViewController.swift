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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let cameraVC = CBCameraViewController()
        presentViewController(cameraVC, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


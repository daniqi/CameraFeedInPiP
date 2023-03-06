//
//  PreviewView.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 06/03/2023.
//

import UIKit
import AVKit

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoDisplayLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
 
    public init(captureSession: AVCaptureSession) {
        super.init(frame: .zero)
        
        videoDisplayLayer.session = captureSession
        videoDisplayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoDisplayLayer.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

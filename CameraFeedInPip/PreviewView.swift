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
    
    // TOOD: use AVSampleBufferDisplayLayer
    // https://stackoverflow.com/questions/71419635/how-to-add-picture-in-picture-pip-for-webrtc-video-calls-in-ios-swift
    
    // Deze zet het om view naar buffer:
    // https://github.com/uakihir0/UIPiPView/blob/main/UIPiPView/Classes/UIView%2B.swift
    
    // Capture output:
    // https://anuragajwani.medium.com/how-to-process-images-real-time-from-the-ios-camera-9c416c531749
    
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

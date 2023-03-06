//
//  PreviewView.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 06/03/2023.
//

import UIKit
import AVKit

class PreviewView: UIView {
    
    var previewLayer: AVCaptureVideoPreviewLayer?

    public init(captureSession: AVCaptureSession) {
        
        super.init(frame: .zero)
        
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        DispatchQueue.main.async {
            self.previewLayer?.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
        }
        
        layer.addSublayer(previewLayer!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

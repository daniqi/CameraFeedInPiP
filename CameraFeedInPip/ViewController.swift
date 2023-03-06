//
//  ViewController.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 06/03/2023.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    private var activatePipButton: UIButton = {
       var button = UIButton()
        button.setTitle("Activate Pip", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()
    
    private var previewView: PreviewView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addButtonToView()
        captureCamera()
        previewView = PreviewView(captureSession: captureSession)
        addPreviewView()
    }
     
    var captureSession: AVCaptureSession = AVCaptureSession()
    var frontInput: AVCaptureInput?

    private func captureCamera() {
        if let frontDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first {
            frontInput = try! AVCaptureDeviceInput(device: frontDevice)
        }
        
        captureSession.beginConfiguration()
        if let front = frontInput, captureSession.canAddInput(front) == true {
          captureSession.addInput(front)
        }

        captureSession.commitConfiguration()
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        
        backgroundQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    @objc
    private func startPip() {
        let pipVideoController = AVPictureInPictureVideoCallViewController()
        pipVideoController.view?.addSubview(self.view)
        
        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: previewView!,
                contentViewController: pipVideoController)
        
        
        present(pipVideoController, animated: false)
//        let pipController = AVPictureInPictureController(contentSource: pipContentSource)
        
//        pipVideoController.preferredContentSize = view.frame.size
//
//        // To start PiP automatically when app goes to background
//        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        
//        pipController.playerLayer.player?.play()
//
//        print(pipController.playerLayer.isReadyForDisplay)
//
//        // Or you can start PiP manually
//        pipController.startPictureInPicture()
    }
    
    private func addButtonToView() {
        activatePipButton.addTarget(self, action: #selector(startPip), for: .touchUpInside)
        view.addSubview(activatePipButton)
        
        NSLayoutConstraint.activate([
            activatePipButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            activatePipButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 80),
        ])
    }
    
    private func addPreviewView() {
        view.addSubview(previewView!)
        
        NSLayoutConstraint.activate([
            previewView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 10),
            previewView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10),
            previewView!.widthAnchor.constraint(equalToConstant: 500),
            previewView!.heightAnchor.constraint(equalToConstant: 500),
        ])
    }
}


//
//  ViewController.swift
//  CameraFeedInPip
//
//  Created by Danick Sikkema on 06/03/2023.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var pipVideoCallViewController: AVPictureInPictureVideoCallViewController?
    
    private var createVideoControllerButton: UIButton = {
       var button = UIButton()
        button.setTitle("CreateVideoController", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()
    
    private var previewView: PreviewView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addCreateVideoControllerButtonToView()
        captureCamera()
        previewView = PreviewView(captureSession: captureSession)
        addPreviewView()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.sessionWasInterrupted(notification:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: captureSession)
        
    }
     
    var captureSession: AVCaptureSession = AVCaptureSession()
    var frontInput: AVCaptureInput?
    
    @objc func sessionWasInterrupted(notification: Notification) {
        print(notification)
    }

    private func captureCamera() {
        if let frontDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first {
            frontInput = try! AVCaptureDeviceInput(device: frontDevice)
        }
        
        captureSession.beginConfiguration()
        if let front = frontInput, captureSession.canAddInput(front) == true {
          captureSession.addInput(front)
        }

        captureSession.commitConfiguration()
        captureSession.isMultitaskingCameraAccessEnabled = true
        
        print(captureSession.isMultitaskingCameraAccessSupported)
        print(captureSession.isMultitaskingCameraAccessEnabled)
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        
        backgroundQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    @objc
    private func createVideoCallController() {
        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        pipVideoCallViewController?.view?.addSubview(self.previewView!)
        
        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: self.previewView!,
                contentViewController: pipVideoCallViewController!)
        
//        let pipController = AVPictureInPictureController(contentSource: pipContentSource)
//        pipController.canStartPictureInPictureAutomaticallyFromInline = true
//        pipController.delegate = self
//
//        pipVideoCallViewController!.preferredContentSize = view.frame.size
//        pipController.startPictureInPicture()
        
    }
    
    private func addCreateVideoControllerButtonToView() {
        createVideoControllerButton.addTarget(self, action: #selector(createVideoCallController), for: .touchUpInside)
        view.addSubview(createVideoControllerButton)
        
        NSLayoutConstraint.activate([
            createVideoControllerButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            createVideoControllerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
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

extension ViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller will start pip")
        print(pictureInPictureController)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("error when starintg pip")
        print(error)
    }
    
}

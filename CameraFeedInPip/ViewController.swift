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
    
    private var startPipButton: UIButton = {
       var button = UIButton()
        button.setTitle("Start PiP", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        return button
    }()
    
    private var previewView: PreviewView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        captureCamera()
        previewView = PreviewView(captureSession: captureSession)
        
        
        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        pipVideoCallViewController?.view?.addSubview(self.previewView!)
        
        view.addSubview(pipVideoCallViewController!.view)
        
        addStartPiPButton()
        
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

        captureSession.isMultitaskingCameraAccessEnabled = true
        captureSession.commitConfiguration()
        
        print("multitaskingCameraAccessSupported: \(captureSession.isMultitaskingCameraAccessSupported)")
        print("multitaskingCameraAccessEnabled: \(captureSession.isMultitaskingCameraAccessEnabled)")
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        
        backgroundQueue.async {
            self.captureSession.startRunning()
        }
        
    }
    
    @objc
    private func startPip() {
        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: self.pipVideoCallViewController!.view,
                contentViewController: pipVideoCallViewController!)

        let pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        pipController.delegate = self

        pipController.startPictureInPicture()
        
    }
    
    private func addStartPiPButton() {
        startPipButton.addTarget(self, action: #selector(startPip), for: .touchUpInside)
        view.addSubview(startPipButton)
        
        NSLayoutConstraint.activate([
            startPipButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            startPipButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
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

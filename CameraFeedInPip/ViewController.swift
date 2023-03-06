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
    
    private let videoOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSession()
        captureCamera()
        previewView = PreviewView(captureSession: captureSession!)
        
        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        pipVideoCallViewController?.view?.addSubview(self.previewView!)
        
        view.addSubview(pipVideoCallViewController!.view)
        
        addStartPiPButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.sessionWasInterrupted(notification:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: captureSession)
        
    }
     
    var captureSession: AVCaptureSession?
    var frontInput: AVCaptureInput?
    
    @objc func sessionWasInterrupted(notification: Notification) {
        print(notification)
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        guard let device = deviceDiscoverySession.devices.first else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        captureSession?.addInput(input)
        
        self.addVideoOutput()
    }
    
    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession?.addOutput(self.videoOutput)
    }

    private func captureCamera() {
        print("multitaskingCameraAccessSupported: \(captureSession?.isMultitaskingCameraAccessSupported)")
        print("multitaskingCameraAccessEnabled: \(captureSession?.isMultitaskingCameraAccessEnabled)")
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background)
        
        backgroundQueue.async {
            self.captureSession?.startRunning()
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

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        print(frame)
        print("did receive image frame")
        // process image here
    }
}

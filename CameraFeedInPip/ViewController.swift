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
    
    var pipController: AVPictureInPictureController?
    
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
        
//        present(pipVideoCallViewController!, animated: false)
        view.addSubview(pipVideoCallViewController!.view)
        
        setupPipController()
        addStartPiPButton()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.sessionWasInterrupted(notification:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: captureSession)
        
    }
     
    var captureSession: AVCaptureSession?
    var frontInput: AVCaptureInput?
    
    @objc func sessionWasInterrupted(notification: Notification) {
        print(notification)
    }
    
    private func setupPipController() {
        
        let source = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: self.previewView!.sampleBufferDisplayLayer, playbackDelegate: self)
        
//        let pipContentSource = AVPictureInPictureController.ContentSource(
//            activeVideoCallSourceView: previewView!,
//                contentViewController: pipVideoCallViewController!)

        pipController = AVPictureInPictureController(contentSource: source)
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipController?.delegate = self
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        guard let device = deviceDiscoverySession.devices.first else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        captureSession?.addInput(input)
        
        // Enable MultitaskingCamera
        captureSession?.isMultitaskingCameraAccessEnabled = true
        
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
        if pipController!.isPictureInPictureActive {
            print("stop")
            pipController?.stopPictureInPicture()
        } else {
            print("start")
            pipController?.startPictureInPicture()
        }
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

extension ViewController: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        print("test")
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        return CMTimeRange()
    }

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        return true
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
        print("test")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        print("test")
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
        
//        print(frame)
//        print("did receive image frame")
        // process image here
    }
}

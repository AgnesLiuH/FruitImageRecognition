//
//  ViewController.swift
//  FruitImageRecognition
//
//  Created by Agnes Liu on 12/6/18.
//  Copyright © 2018 Agnes Liu. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var mutableAttributedString = NSMutableAttributedString()
    let label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initLabel()
        setCapture()
        view.addSubview(label)
        setLabel()
    }
    

    
    func setCapture() {
        
        //instantiate a new AVCaptureSession
        let capture = AVCaptureSession()
        //Set devices
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        do {
            if let captureDevice = availableDevices.first {
                capture.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }
        let captureOutput = AVCaptureVideoDataOutput()
        capture.addOutput(captureOutput)
        
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        let preview = AVCaptureVideoPreviewLayer(session: capture)
        preview.frame = view.frame
        view.layer.addSublayer(preview)
        
        capture.startRunning()
    }
    
    //The output part, which is used to show the output reflected by model
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //The ImageClassifier is the model.
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model)
            else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let Observation = results.first
                else { return }
            
            DispatchQueue.main.async(execute: {
                self.updateLabel(text: "\(Observation.identifier)\n confidence: \(Observation.confidence)")
            })
        }
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    //The label part
    func initLabel() {
        let defaultText = "Agnes's project"
        self.label.adjustsFontSizeToFitWidth = true
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.numberOfLines = 0
        let myAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.white,
            NSAttributedString.Key.foregroundColor : UIColor.blue,
            NSAttributedString.Key.strokeWidth : -1.0,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)
            ] as [NSAttributedString.Key : Any]
        mutableAttributedString = NSMutableAttributedString(string: defaultText, attributes: myAttributes);
        self.label.attributedText = mutableAttributedString
    }
    
    func updateLabel(text: String) {
        mutableAttributedString.mutableString.setString(text)
        self.label.attributedText = mutableAttributedString
    }
    
    func setLabel() {
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    }
    
    
}



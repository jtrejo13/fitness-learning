/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the CoreMotion interactions and 
         provides a delegate to indicate changes in data.
 */

import Foundation
import CoreMotion
import WatchKit
import os.log
/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: class {
    func didUpdateMotion(_ manager: MotionManager, gravityStr: String, rotationRateStr: String, userAccelStr: String, attitudeStr: String, prediction:String)
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

class MotionManager {
    // MARK: Properties
    
    let theta1 = [11.149,    -1.6496,    -2.5578,    0.18047,    -0.63865,    -1.0305,   -0.82277,    -1.8907,
                  -2.0255,    -1.7771,    -2.0681,    -1.5767,    -1.9441,    -1.8621]
    let theta2 = [2.4541,    8.3452,    -7.8079,    -11.527,    0.31066,    0.44647,    -0.040977,    4.9584,    3.4946,
                  4.0185,     -1.0828,    -1.1043,    -2.1308,    0.52694]
    let theta3 = [-5.4841,    -1.8485,    0.22756,    -0.47925,    0.039934,    -0.074275,    -0.12836,    1.0105,
                  1.1816,    -2.7029,    0.54086,    -0.32585,    1.7187,    1.3845]
    let theta4 = [-25.715,    0.28693,    2.4225,    0.072567,    0.72679,    0.20328,    0.31253,    0.63696,
                  2.75,    10.144,    1.1484,    1.9702,    -1.3331,    -3.7885]
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left

    // MARK: Application Specific Constants
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 50
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    weak var delegate: MotionManagerDelegate?
    
    var gravityStr = ""
    var rotationRateStr = ""
    var userAccelStr = ""
    var attitudeStr = ""
    var prediction = ""
    var data: [Double] = []
    var accelx = 0.0
    var accely = 0.0
    var accelz = 0.0
    var accel = 0.0

    var recentDetection = false

    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }

    // MARK: Motion Manager

    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        os_log("Start Updates");

        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }

            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }

    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    // MARK: Motion Processing
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        gravityStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                            deviceMotion.gravity.x,
                            deviceMotion.gravity.y,
                            deviceMotion.gravity.z)
        userAccelStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                           deviceMotion.userAcceleration.x,
                           deviceMotion.userAcceleration.y,
                           deviceMotion.userAcceleration.z)
        rotationRateStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                              deviceMotion.rotationRate.x,
                              deviceMotion.rotationRate.y,
                              deviceMotion.rotationRate.z)
        attitudeStr = String(format: "r: %.1f p: %.1f y: %.1f" ,
                                 deviceMotion.attitude.roll,
                                 deviceMotion.attitude.pitch,
                                 deviceMotion.attitude.yaw)
        
        accelx = deviceMotion.userAcceleration.x + deviceMotion.gravity.x
        accely = deviceMotion.userAcceleration.y + deviceMotion.gravity.y
        accelz = deviceMotion.userAcceleration.z + deviceMotion.gravity.z
        
        accel = sqrt(accelx * accelx + accely * accely + accelz * accelz)
        
        data = [deviceMotion.attitude.roll, deviceMotion.attitude.pitch, deviceMotion.attitude.yaw,
                deviceMotion.rotationRate.x, deviceMotion.rotationRate.y, deviceMotion.rotationRate.z,
                deviceMotion.gravity.x, deviceMotion.gravity.y, deviceMotion.gravity.z,
                deviceMotion.userAcceleration.x, deviceMotion.userAcceleration.y, deviceMotion.userAcceleration.z,
                accel]
        
        prediction = predictWorkout(data);
        
//        let timestamp = Date().millisecondsSince1970
        
        os_log("Prediction: %@ ", String(prediction))
        
        updateMetricsDelegate();
    }
    
    func predictWorkout(_ data: [Double]) -> String {
        var predictions: [Double] = [0, 0, 0, 0]
        
        predictions[0] = hfun(theta1, data)
        predictions[1] = hfun(theta2, data)
        predictions[2] = hfun(theta3, data)
        predictions[3] = hfun(theta4, data)
        
        let max_val = predictions.max()
        
        if max_val == predictions[0] {
            return "Elliptical"
        } else if max_val == predictions[1] {
            return "Pushups"
        } else if max_val == predictions[2] {
            return "Rowing"
        } else if max_val == predictions[3] {
            return "Treadmill"
        } else {
            return ""
        }
    }
    
    func hfun(_ theta:[Double], _ data:[Double]) -> Double {
        var sum:Double = theta[0]
        for i in 0..<data.count {
            sum = sum + theta[i+1] * data[i]
        }
        return sum
    }
    
    func sigmoid(_ value: Double) -> Double {
        return 1.0 / (1.0 + exp(-1 * value))
    }
    

    // MARK: Data and Delegate Management
    
    func updateMetricsDelegate() {
        delegate?.didUpdateMotion(self,gravityStr:gravityStr, rotationRateStr: rotationRateStr, userAccelStr: userAccelStr, attitudeStr: attitudeStr, prediction: prediction)
    }
}

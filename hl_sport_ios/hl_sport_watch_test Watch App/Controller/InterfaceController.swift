//
//  InterfaceController.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/6/9.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        crownSequencer.delegate = self
        crownSequencer.focus()
        crownSequencer.isHapticFeedbackEnabled = true
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension InterfaceController: WKCrownDelegate {
    
    //表冠旋转
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        print("旋转度数：\(rotationalDelta)")
    }
    
    //空闲
    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        
    }
}

//
//  chatController.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/2/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class BumpController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            var storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var chat:SessionCounterController = storyboard.instantiateViewControllerWithIdentifier("SessionCounter") as SessionCounterController
            self.navigationController?.pushViewController(chat, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

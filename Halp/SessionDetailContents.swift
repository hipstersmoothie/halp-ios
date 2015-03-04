//
//  SessionDetailContents.swift
//  Halp
//
//  Created by Andrew Lisowski on 3/4/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class SessionDetailContents: UIView {
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("content touched")
        self.endEditing(true);
    }
}

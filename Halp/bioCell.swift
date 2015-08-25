//
//  bioCell.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/12/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class bioCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet var bio: UITextView!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

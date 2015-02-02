//
//  tutorRow.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/1/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import Foundation
import UIKit

class reviewRow: UITableViewCell {
    @IBOutlet var rating: FloatRatingView!
    @IBOutlet var title: UILabel!
    @IBOutlet var reviewBody: UITextView!
}

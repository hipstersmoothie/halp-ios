//
//  TutorList.swift
//  Halp
//
//  Created by Andrew Lisowski on 1/28/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class tutor: NSObject {
    var name:String
    var rating:Int
    var pph:Int
    var profilePic:UIImage
    var university:String
    var major:String
    var year:Int
    var classes:[String]
    var reviews:[review]
    
    init(nameI: String, ratingI: Int, pricePerHour: Int, pic: UIImage, uni: String, major:String, year:Int, classes:[String], reviews:[review]) {
        name = nameI
        rating = ratingI
        pph = pricePerHour
        profilePic = pic
        university = uni
        self.major = major
        self.year = year
        self.classes = classes
        self.reviews = reviews
    }
}

class review:NSObject {
    var title:String
    var reviewBody:String
    var rating:Int
    
    init(title:String, reviewBody:String, rating:Int) {
        self.title = title
        self.reviewBody = reviewBody
        self.rating = rating
    }
}

func setRating(cell: UIImageView, rating: Int) {
    if rating == 1 {
        cell.image = UIImage(named: "1-stars.png")
    } else if rating == 2 {
        cell.image = UIImage(named: "2-stars.png")
    } else if rating == 3 {
        cell.image = UIImage(named: "3-stars.png")
    } else if rating == 4 {
        cell.image = UIImage(named: "4-stars.png")
    } else if rating == 5 {
        cell.image = UIImage(named: "5-stars.png")
    } else  {
        cell.image = UIImage(named: "0-stars.png")
    }
}

var selectedTutor:tutor!

class TutorList: UITableViewController, UITableViewDelegate {
    @IBOutlet var nav: UINavigationItem!
    
    var tutors:[tutor] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rev = review(title: "Great Tutor", reviewBody: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.", rating: 5)
        let rev1 = review(title: "Aweful", reviewBody: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.", rating: 1)
        let rev2 = review(title: "Helped a Little", reviewBody: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.", rating: 3)
        var reviewslist = [rev, rev1, rev2]
        var kyle = tutor(nameI: "Kyle", ratingI: 4, pricePerHour: 15, pic: UIImage(named: "tutor.jpeg")!, uni: "UCLA", major: "Business", year: 2, classes: ["BUS210", "ECON215", "ENGL134"], reviews: reviewslist)
        var harry = tutor(nameI: "Harry", ratingI: 2, pricePerHour: 12, pic: UIImage(named: "tutor.jpeg")!, uni: "SFSU", major: "Business", year: 2, classes: ["BOT121", "ART201", "MATH100"], reviews: reviewslist)
        var tanner = tutor(nameI: "Tanner", ratingI: 3, pricePerHour: 18, pic: UIImage(named: "tutor.jpeg")!, uni: "ICON Acedemy", major: "Productyear: ion", year: 3, classes: ["MUS200", "MUS340", "CSC101"], reviews: reviewslist)
        var emma = tutor(nameI: "Emma", ratingI: 5, pricePerHour: 20, pic: UIImage(named: "tutor.jpeg")!, uni: "Cal Poly SLO", major: "Computer Science", year: 1, classes: ["CSC101", "CPE365", "ENGL139"], reviews: reviewslist)
        tutors.append(kyle)
        tutors.append(harry)
        tutors.append(tanner)
        tutors.append(emma)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tutors.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedTutor = tutors[indexPath.row]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: tutorRow = tableView.dequeueReusableCellWithIdentifier("tutorCell") as tutorRow
        
        let user = tutors[indexPath.row]
        cell.myLabel.text = user.name
        setRating(cell.myImageView, user.rating)
        
        return cell;
    }

}

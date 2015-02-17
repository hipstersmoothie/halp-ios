//
//  ActivityIndicatorHelper.swift
//  Halp
//
//  Created by Andrew Lisowski on 2/5/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

func pause(view: UIView) {
    activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
}

func start(view: UIView) {
    activityIndicator.stopAnimating()
    UIApplication.sharedApplication().endIgnoringInteractionEvents()
}

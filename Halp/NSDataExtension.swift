//
//  NSDataExtension.swift
//  Halp
//
//  Created by Andrew Lisowski on 3/13/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import Foundation

extension NSData {
    func hexString() -> NSString {
        var str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
}
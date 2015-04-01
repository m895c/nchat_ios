//
//  GenderFixer.swift
//  nchat
//
//  Created by Evan Carmi on 3/31/15.
//  Copyright (c) 2015 Evan Carmi. All rights reserved.
//

import Foundation

class GenderFixer {
    class func currentGenderAsBool() -> Bool {
        var sex = true
        let gender = genderFromProfile()
        if gender != nil {
            switch gender! {
                case "male": sex = true
                case "female": sex = false
                default: sex = true
            }
        }
        return sex
    }
    
    class func suggestedTargetGenderAsBool() -> Bool {
        return !currentGenderAsBool()
    }
    
    class func genderFromProfile() -> String? {
        let delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        return delegate.fbProfile?["gender"]! as String?
    }
}
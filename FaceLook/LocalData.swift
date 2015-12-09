//
//  LocalData.swift
//  FaceLook
//
//  Created by Brent on 2015-12-04.
//  Copyright © 2015 Brent Marykuca. All rights reserved.
//

import Foundation
import Contacts

var LocalData = _LocalData()

class _LocalData
{
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    func synchronize()
    {
        defaults.synchronize()
    }
    
    let contactStore = CNContactStore()
    
    var currentContactID: String?
    {
        get { return defaults.stringForKey("currentContactID") }
        set { defaults.setObject(newValue, forKey: "currentContactID") }
    }
}


//
//  ViewController.swift
//  FaceLook
//
//  Created by Brent on 2015-12-03.
//  Copyright © 2015 Brent Marykuca. All rights reserved.
//

import UIKit
import Contacts

class InitialViewController: UIViewController
{
    let authStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        switch authStatus
        {
            case .NotDetermined:
                print("Not Determined")
                runOnMainQueue {
                    self.performSegueWithIdentifier("ShowPermissionsSegue", sender: self)
                }
            
            case .Authorized:
                print("Authorized")
                runOnMainQueue {
                    self.performSegueWithIdentifier("InitialToFacesSegue", sender: self)
                }

            case .Denied, .Restricted:
                print("Denied or Restricted")

                runOnMainQueue {
                    self.performSegueWithIdentifier("ShowPermissionsSegue", sender: self)
                }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let showPermissionsViewController = segue.destinationViewController as? PermissionViewController
        {
            if [.Denied, .Restricted].contains(authStatus)
            {
                showPermissionsViewController.viewStyle = .ReferToSettings
            }
        }
    }

}


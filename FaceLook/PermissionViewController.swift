//
//  PermissionViewController.swift
//  FaceLook
//
//  Created by Brent on 2015-12-04.
//  Copyright © 2015 Brent Marykuca. All rights reserved.
//

import Foundation
import UIKit
import Contacts

enum PermissionViewStyle
{
    case AskPermission
    case ReferToSettings
}

class PermissionViewController: UIViewController
{
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var grantButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.updateUI()
    }
    
    private func updateUI()
    {
        if self.isViewLoaded()
        {
            switch self.viewStyle
            {
                case .AskPermission:
                    self.promptLabel.text = "FaceLook needs your permission to access your contacts."
                    self.grantButton.setTitle("Grant Permission", forState: .Normal)


                case .ReferToSettings:
                    self.promptLabel.text =
                        "FaceLook does not have permission to access your contacts.\n\nYou can adjust this in your Privacy Settings."
                    self.grantButton.setTitle("Open Settings", forState: .Normal)
            }
        }
    }
    
    var viewStyle:PermissionViewStyle = .AskPermission
    
    private func requestPermission()
    {
        LocalData.contactStore.requestAccessForEntityType(.Contacts, completionHandler: { granted, error in
            runOnMainQueue {
                if granted
                {
                    self.performSegueWithIdentifier("ShowFacesSegue", sender: self)
                }
                else
                {
                    self.viewStyle = .ReferToSettings
                    self.updateUI()
                }
            }
        })
    }

    @IBAction func grantPermissionAction(sender: AnyObject)
    {
        switch self.viewStyle
        {
            case .AskPermission:
                requestPermission()

            case .ReferToSettings:
                if let openSettingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
                {
                    UIApplication.sharedApplication().openURL(openSettingsURL)
                }
        }
    }
}

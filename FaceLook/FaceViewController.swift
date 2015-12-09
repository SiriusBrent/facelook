//
//  FaceViewController.swift
//  FaceLook
//
//  Created by Brent on 2015-12-03.
//  Copyright © 2015 Brent Marykuca. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import ContactsUI

class FaceViewController: UIViewController, UIGestureRecognizerDelegate
{
    var contact: CNContact!
    var index: Int = 0
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBAction func faceTapped(sender: AnyObject!)
    {
        do {
        
            let unifiedContact = try LocalData.contactStore.unifiedContactWithIdentifier(contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        
            let cnvc = CNContactViewController(forContact: unifiedContact)
     
            self.navigationController?.pushViewController(cnvc, animated: true)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        catch let error as NSError
        {
            print(error)
        }
    }
}
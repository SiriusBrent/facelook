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

class FacesViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    var faces = [FaceViewController]()
    
    override func viewWillAppear(animated: Bool)
    {
        self.dataSource = self
        self.delegate = self
        self.navigationController?.navigationBarHidden = true
        if faces.count == 0
        {
            let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey,
                CNContactThumbnailImageDataKey, CNContactImageDataKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactTypeKey])
            do {
                try LocalData.contactStore.enumerateContactsWithFetchRequest(fetchRequest) { (contact, status) -> Void in
                    print(contact.givenName, contact.familyName)
                    if let imageData = contact.imageData
                    {
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FaceViewController") as! FaceViewController
                        controller.loadView()
                        controller.faceImageView.image = UIImage(data: imageData)
                        controller.contact = contact
                        controller.index = self.faces.count
                        self.faces.append(controller)
                        if controller.contact.contactType == .Organization
                        {
                            controller.nameLabel.text = controller.contact.organizationName
                            if controller.contact.departmentName.utf8.count > 0
                            {
                                controller.nameLabel.text = (controller.nameLabel.text ?? "") + "\n" + controller.contact.departmentName
                            }
                        }
                        else
                        {
                            let nc = NSPersonNameComponents()
                            nc.givenName = contact.givenName
                            nc.familyName = contact.familyName
                            let formattedName = NSPersonNameComponentsFormatter.localizedStringFromPersonNameComponents(nc, style: .Default, options: [])
                            controller.nameLabel.text = formattedName
                        }
                    }
                }
            }
            catch let error as NSError
            {
                print(error)
            }
        }
                
        
        if faces.count > 0
        {
            let currentContactID = LocalData.currentContactID
            let faceIndex = faces.indexOf { controller in
                return controller.contact.identifier == currentContactID
            }
                
            self.setViewControllers([faces[faceIndex ?? 0]], direction: .Forward, animated: false, completion: {done in })
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController])
     {
        let nextController = pendingViewControllers[0] as! FaceViewController
        LocalData.currentContactID = nextController.contact.identifier
        print(nextController.contact.identifier)
     }
 
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        guard viewController != faces.first else
        {
            return nil
        }
        return faces[faces.indexOf(viewController as! FaceViewController)! - 1]
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        guard viewController != faces.last else
        {
            return nil
        }
        return faces[faces.indexOf(viewController as! FaceViewController)! + 1]
    }
    
}

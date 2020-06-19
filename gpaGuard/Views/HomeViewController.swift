//
//  HomeViewController.swift
//  gpaGuard
//
//  Created by Sri Kamal Venkata Chillarage on 6/18/20.
//  Copyright © 2020 Sri Kamal Venkata Chillarage. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class HomeViewController: UIViewController
{
	@IBOutlet var signoutFB: UIView!
	
	override func viewDidLoad()
	{
		
	}
	
	@IBAction func signOutFb(_ sender: Any)
	{
		LoginManager().logOut()
		print("logged out")
	}
	
}

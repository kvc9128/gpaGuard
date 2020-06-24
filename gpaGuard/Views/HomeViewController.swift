//
//  HomeViewController.swift
//  gpaGuard
//
//  Created by Sri Kamal Venkata Chillarage on 6/18/20.
//  Copyright © 2020 Sri Kamal Venkata Chillarage. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class HomeViewController: UIViewController
{
	@IBOutlet var signoutFB: UIView!
	
	override func viewDidLoad()
	{
		
	}
	
	@IBAction func signOutFb(_ sender: Any)
	{
		LoginManager().logOut()
		GIDSignIn.sharedInstance().signOut()
		print("logged out")
	}
	
	
	@IBAction func studyButtonPressed(_ sender: Any)
	{
		//Perform database entry operations here such as adding user to student database
		
		// segue
		//self.performSegue(withIdentifier: K.studySegue, sender: self)
	}
	
	@IBAction func tutorButtonPressed(_ sender: Any)
	{
		//Perform database entry operations here such as adding user to tutor database
		
		// segue
		//self.performSegue(withIdentifier: K.tutorSegue, sender: self)
	}
}

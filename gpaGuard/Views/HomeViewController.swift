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
	var username:String?
	
	override func viewDidLoad()
	{
		if((AccessToken.current) != nil)
		{
			 GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) -> Void in
				 if (error == nil){

					 let dict = result as! [String : AnyObject]
					 print(result!)
					 print(dict)
					 let picutreDic = dict as NSDictionary

					 let nameOfUser = picutreDic.object(forKey: "name") as! String

					 var tmpEmailAdd = ""
					 if let emailAddress = picutreDic.object(forKey: "email")
					 {
						 tmpEmailAdd = emailAddress as! String
						 //print(tmpEmailAdd)
					 }
					 else {
						 var usrName = nameOfUser
						 usrName = usrName.replacingOccurrences(of: " ", with: "")
						 tmpEmailAdd = usrName+"@facebook.com"
					 }
					print("Name of User: ", nameOfUser)
					self.username = nameOfUser
					print("Email of User: ", tmpEmailAdd)
//					if !self.doesUserExist(username: nameOfUser)
//					{
//						let newUser = self.createUser(username: nameOfUser, email: tmpEmailAdd, password: nil)
//						self.savedata(user: newUser)
//					}
				 }
				else
				{
					print("errori9hg out here: ")
					print(error?.localizedDescription as Any)
				}
			 })
		 }
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

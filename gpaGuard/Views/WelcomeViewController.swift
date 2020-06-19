//
//  ViewController.swift
//  gpaGuard
//
//  Created by Sri Kamal Venkata Chillarage on 6/17/20.
//  Copyright © 2020 Sri Kamal Venkata Chillarage. All rights reserved.
//

import UIKit
import AmplifyPlugins
import Amplify
import CryptoKit
import Combine
import GoogleSignIn
import FBSDKLoginKit

class WelcomeViewController: UIViewController
{
	
	var userSubscription: AnyCancellable?
	
	@IBOutlet weak var infoLabel: UILabel!
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		
		if let token = AccessToken.current, !token.isExpired
			{
				getFBUserData()
				self.performSegue(withIdentifier: K.socialSignInSegue, sender: self)
		    }
		
		// Do any additional setup after loading the view.
		//LoginManager().logOut()
//		GIDSignIn.sharedInstance()?.presentingViewController = self
//		// Automatically sign in the user.
//		GIDSignIn.sharedInstance()?.restorePreviousSignIn()
			//
		
	}
	
	@IBOutlet weak var FBloginButton: FBLoginButton!
	
	
	// MARK: User Model data activities
	func subscribeTodos()
	{
	   self.userSubscription = Amplify.DataStore.publisher(for: User.self)
			   .sink(receiveCompletion: { completion in
				   print("Subscription has been completed: \(completion)")
			   }, receiveValue: { mutationEvent in
				   print("Subscription got this value: \(mutationEvent)")
			   })
	}
	
	/*
		This method creates and returns a User object based on inputs to be stored in the database
		Takes in username as a compulsary field with optional email, password args
		Secures Password using SHA-256 hashing
	*/
		
	func createUser(username: String, email: String? ,password: String?) ->  User
	{
		if let securePassword = password, let email = email
		{
			let dataPassword = securePassword.data(using: .utf8)!
			let hashPassword = SHA256.hash(data: dataPassword)
			let hashString = hashPassword.map { String(format: "%02hhx", $0) }.joined()
			return User(username: username, email: email, password: hashString)
		}
		else if let email = email
		{
			return User(username: username, email: email, password: password)
		}
		else
		{
			return User(username: username)
		}
	}

	/*
		This method takes in a User object created by createUser and stores it in the dynamoDB table
	*/
	func savedata(user: User)
	{
		print("DSKJCNDSJBV")
		print("username, email: ", user.username, user.email ?? "email not found")
		Amplify.DataStore.save(user) { (result) in
		switch(result)
		{
		case .success(let savedUser):
			print("Updated item: \(savedUser.username )")
		case .failure(let error):
			print("Could not update data in Datastore: \(error)")
		}
		}
	}

	
	/*
		Based on username, this method updates user information
	*/
	func updateUser(currentUsername: String, newUsername: String)
	{
		Amplify.DataStore.query(User.self, where: User.keys.username.eq(currentUsername)) { (result) in
			switch(result)
			{
			case .success(let users):
				guard users.count == 1, var updatedUser = users.first else {
					print("Did not find exactly one entry : Bailing out")
					return
				}
				updatedUser.username = newUsername
				Amplify.DataStore.save(updatedUser) { (result) in
					switch(result) {
					case .success(let savedTodo):
						print("Updated item: \(savedTodo.username )")
					case .failure(let error):
						print("Could not update data in Datastore: \(error)")
					}
				}
					
			case .failure(let error):
				print("Could not query items from datastore: \(error)")
			}
		}
	}
	
	/*
		This method retrieves all the users and prints them out
	*/
	func retrieveData()
	{
		Amplify.DataStore.query(User.self) { (result) in
			switch(result)
			{
			case .success(let users):
				for user in users
				{
					print("======================== User ========================")
					print("ID :  \(user.id)")
					print("Username : \(user.username)")
					if let email = user.email, let password = user.password
					{
						print("Email : \(email)")
						print("Password : \(password)")
					}
				}
			case .failure(let error):
				print("Could not query items from datastore: \(error)")
			}
		}
	}
	
	/*
		Based on the username, this method deletes a user from the database
	*/
	func deleteUser(username: String)
	{
		Amplify.DataStore.query(User.self, where: User.keys.username.eq(username)) { (result) in
			switch(result)
			{
			case .success(let users):
				guard users.count == 1, let toDeleteUser = users.first else {
					print("Did not find exactly one todo, bailing")
					return
				}
				Amplify.DataStore.delete(toDeleteUser) { (result) in
					switch(result) {
					case .success:
						print("Deleted item: \(toDeleteUser.username)")
					case .failure(let error):
						print("Could not update data in Datastore: \(error)")
					}
				}
			case .failure(let error):
				print("Could not query DataStore: \(error)")
			}
		}
		retrieveData()
	}
	
	@IBAction func FacebookLogin(_ sender: FBLoginButton)
	{

	}
	
	func getFBUserData() {
		 //which if my function to get facebook user details
		 if((AccessToken.current) != nil){
			 
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
					print("Email of User: ", tmpEmailAdd)
					let newUser = self.createUser(username: nameOfUser, email: tmpEmailAdd, password: nil)
					self.savedata(user: newUser)
				 }
				else
				{
					print(error?.localizedDescription as Any)
				}
			 })
		 }
	 }
}


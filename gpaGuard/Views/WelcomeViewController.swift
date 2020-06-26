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

class WelcomeViewController: UIViewController, GIDSignInDelegate
{
	
	@IBOutlet weak var FBloginButton: FBLoginButton!
	var username: String?
	var subscription: GraphQLSubscriptionOperation<User>?
	// MARK: User Model data activities
	//var userSubscription: AnyCancellable?
	
//	func subscribeUsers()
//	{
//	   self.userSubscription = Amplify.DataStore.publisher(for: User.self)
//			   .sink(receiveCompletion: { completion in
//				   print("Subscription has been completed: \(completion)")
//			   }, receiveValue: { mutationEvent in
//				   print("Subscription got this value: \(mutationEvent)")
//			   })
//	}
	
	/*
		This method creates and returns a User object based on inputs to be stored in the database
		Takes in username as a compulsary field with optional email, password args
		Secures Password using SHA-256 hashing
	*/
	
	
	func createSubscription() {
		subscription = Amplify.API.subscribe(request: .subscription(of: User.self, type: .onCreate), valueListener: { (subscriptionEvent) in
			switch subscriptionEvent {
			case .connection(let subscriptionConnectionState):
				print("Subscription connect state is \(subscriptionConnectionState)")
			case .data(let result):
				switch result {
				case .success(let createdTodo):
					print("Successfully got todo from subscription: \(createdTodo)")
				case .failure(let error):
					print("Got failed result with \(error.errorDescription)")
				}
			}
		}) { result in
			switch result {
			case .success:
				print("Subscription has been closed successfully")
			case .failure(let apiError):
				print("Subscription has terminated with \(apiError)")
			}
		}
	}
	
	
		
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
//		print(user)
//		Amplify.DataStore.save(user) { (result) in
//			switch(result)
//			{
//			case .success(let user):
//				print("Succesfully created user: \(user)")
//			case .failure(let error):
//				print("Error occurred and unable to create user: \(error)")
//			}
//		}
		print(user, "user alp fdf")
		_ = Amplify.API.mutate(request: .create(user))
		{
			event in switch event {
			case .success(let result):
				print(result)
				switch result {
				case .success(let user):
					print("Useralp: ")
					print("Successfully created user: \(user)")
				case .failure(let error):
					print("Got failed result with \(error.errorDescription)")
				}
			case .failure(let error):
				print("Got failed event with error \(error)")
			}
		}
	}

	
	/*
		Based on username, this method updates user information
	*/
	func updateUser(currentUsername: String, newUsername: String)
	{
		let user = User.keys
		let predicate = user.username == currentUsername
		_ = Amplify.API.query(request: .list(User.self, where: predicate)){ event in
			switch event
			{
				case .success(let result):
					switch result {
						case .success(let users):
								guard users.count == 1, var updatedUser = users.first else
								{
									print("Did not find exactly one entry : Bailing out")
									return
								}
								updatedUser.username = newUsername
								_ = Amplify.API.mutate(request: .update(updatedUser)) { event in
									switch event
									{
									case .success(let result):
										switch result
										{
											case .success(let user):
												print("Successfully updated user: \(user)")
											case .failure(let error):
												print("Got failed result with \(error.errorDescription)")
										}
									case .failure(let error):
										print("Got failed event with error \(error)")
									}
								}
					

					case .failure(let error):
						print("Got failed result with \(error.errorDescription)")
				}
			case .failure(let error):
				print("Got failed event with error \(error)")
			}
		}
		
		
//		Amplify.DataStore.query(User.self, where: User.keys.username.eq(currentUsername)) { (result) in
//			switch(result)
//			{
//			case .success(let users):
//				guard users.count == 1, var updatedUser = users.first else {
//					print("Did not find exactly one entry : Bailing out")
//					return
//				}
//				updatedUser.username = newUsername
//				Amplify.DataStore.save(updatedUser) { (result) in
//					switch(result) {
//					case .success(let savedTodo):
//						print("Updated item: \(savedTodo.username )")
//					case .failure(let error):
//						print("Could not update data in Datastore: \(error)")
//					}
//				}
//
//			case .failure(let error):
//				print("Could not query items from datastore: \(error)")
//			}
//		}
	}
	
	/*
		This method retrieves all the users and prints them out
	*/
	func retrieveData()
	{
		_ = Amplify.API.query(request: .list(User.self)){ event in
			switch event
			{
				case .success(let result):
					switch result {
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
						print("Got failed result with \(error.errorDescription)")
				}
			case .failure(let error):
				print("Got failed event with error \(error)")
			}
		}
		
		
		
//
//		Amplify.DataStore.query(User.self) { (result) in
//			switch(result)
//			{
//			case .success(let users):
//				for user in users
//				{
//					print("======================== User ========================")
//					print("ID :  \(user.id)")
//					print("Username : \(user.username)")
//					if let email = user.email, let password = user.password
//					{
//						print("Email : \(email)")
//						print("Password : \(password)")
//					}
//				}
//			case .failure(let error):
//				print("Could not query items from datastore: \(error)")
//			}
//		}
	}
	
	/*
		Based on the username, this method deletes a user from the database
	*/
	func deleteUser(username: String)
	{
		let user = User.keys
		let predicate = user.username == username
		_ = Amplify.API.query(request: .list(User.self, where: predicate)){ event in
			switch event
			{
				case .success(let result):
					switch result {
						case .success(let users):
							guard users.count == 1, let updatedUser = users.first else
								{
									print("Did not find exactly one entry : Bailing out")
									return
								}
								_ = Amplify.API.mutate(request: .delete(updatedUser)) { event in
									switch event
									{
									case .success(let result):
										switch result
										{
											case .success(let user):
												print("Successfully deleted user: \(user)")
											case .failure(let error):
												print("Got failed result with \(error.errorDescription)")
										}
									case .failure(let error):
										print("Got failed event with error \(error)")
									}
								}
					

					case .failure(let error):
						print("Got failed result with \(error.errorDescription)")
				}
			case .failure(let error):
				print("Got failed event with error \(error)")
			}
		}
		
//		Amplify.DataStore.query(User.self, where: User.keys.username.eq(username)) { (result) in
//			switch(result)
//			{
//			case .success(let users):
//				for user in users
//				{
//					Amplify.DataStore.delete(user) { (result) in
//						switch(result) {
//						case .success:
//							print("Deleted item: \(user.username)")
//						case .failure(let error):
//							print("Could not update data in Datastore: \(error)")
//						}
//					}
//
//				}
//				case .failure(let error):
//				print("Could not query DataStore: \(error)")
//			}
//		}
	}
	
	var flag:Bool = true
	
	func doesUserExist(username: String)
	{
		
		let user = User.keys
		let predicate = user.username == username
		_ = Amplify.API.query(request: .list(User.self, where:predicate)){event in
			switch event
			{
				case .success(let result):
					switch result {
						case .success(let users):
							if users.count != 0
							{
								print("User exists in database, true")
								self.flag = true
								print("Set flag to true: \(self.flag)")
							}
							else{
								print("User does not exist in databaase, false")
								self.flag = false
								print("Set flag to false: \(self.flag)")
							}
					case .failure(let error):
						print("Got failed result with \(error.errorDescription)")
				}
			case .failure(let error):
				print("Got failed event with error \(error)")
			}
		}
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		//subscribeUsers()
//		deleteUser(username: "Sri Kamal Chillarage")
//		deleteUser(username: "Sri Kamal")
		// setting up google sign in delegate, allowing auto sign in if previously signed in and setting presenting view controller
		createSubscription()
		GIDSignIn.sharedInstance()?.delegate = self
		GIDSignIn.sharedInstance()?.presentingViewController = self
		if let user = GIDSignIn.sharedInstance()?.currentUser
		{
			self.username = user.profile.name
		}
		GIDSignIn.sharedInstance()?.restorePreviousSignIn()
		
		
		// Checking if a facebook user has logged in and if so log them in directly
		if let token = AccessToken.current, !token.isExpired
			{
				getFBUserData()
				self.performSegue(withIdentifier: K.socialSignInSegue, sender: self)
		    }
		retrieveData()
	}
	
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
	{
		if let error = error
		{
			print("There was an error logging in: \(error)")
		}
		else
		{
			if let username = user.profile.name, let email = user.profile.email
			{
				doesUserExist(username: username)
				if !flag
				{
					let newUser = createUser(username: username, email: email, password: nil)
					print("userass: \(newUser)")
					savedata(user: newUser)
				}
				self.performSegue(withIdentifier: K.socialSignInSegue, sender: self)
			}
			else if let username = user.profile.name
			{
				if !flag
				{
					print("Creating and saving users")
					let newUser = createUser(username: username, email: nil, password: nil)
					savedata(user: newUser)
				}
				self.performSegue(withIdentifier: K.socialSignInSegue, sender: self)
			}
        }
	}
	
	@IBAction func googleSignin(_ sender: Any)
	{
		self.performSegue(withIdentifier: K.socialSignInSegue, sender: self)
	}
	
	@IBAction func FacebookLogin(_ sender: FBLoginButton)
	{
		/*
			Facebook login flow is a little different. It needs you to login first, then quit the app, then open the app again for data to be stored to database
		*/
	}
	
	func getFBUserData()
	{
//		 which if my function to get facebook user details
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
					self.doesUserExist(username: nameOfUser)
					if !self.flag
					{
						let newUser = self.createUser(username: nameOfUser, email: tmpEmailAdd, password: nil)
						self.savedata(user: newUser)
					}
				 }
				else
				{
					print("errori9hg out here: ")
					print(error?.localizedDescription as Any)
				}
			 })
		 }
	 }
	

}


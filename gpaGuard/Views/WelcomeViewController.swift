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

class WelcomeViewController: UIViewController {

	var userSubscription: AnyCancellable?
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		GIDSignIn.sharedInstance()?.presentingViewController = self
		// Automatically sign in the user.
		GIDSignIn.sharedInstance()?.restorePreviousSignIn()
	}
	
	
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
		Amplify.DataStore.save(user) { (result) in
		   switch(result) {
		   case .success(let savedItem):
			   print("Saved item: \(savedItem.id)")
		   case .failure(let error):
			   print("Could not save item to datastore: \(error)")
		   }
		}
	}
	
	/*
		Based on username, this method updates user information
	*/
	func updateUser(username: String)
	{
		Amplify.DataStore.query(User.self, where: User.keys.username.eq(username)) { (result) in
			switch(result)
			{
			case .success(let users):
				guard users.count == 1, var updatedUser = users.first else {
					print("Did not find exactly one entry : Bailing out")
					return
				}
				updatedUser.username = "Stephanie"
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
	}


}


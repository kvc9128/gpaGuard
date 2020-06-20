//
//  AppDelegate.swift
//  gpaGuard
//
//  Created by Sri Kamal Venkata Chillarage on 6/17/20.
//  Copyright © 2020 Sri Kamal Venkata Chillarage. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate
{
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
	{
		if let error = error {
		  if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
			print("The user has not signed in before or they have since signed out.")
		  } else {
			print("\(error.localizedDescription)")
		  }
		  return
		}
	}
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions)
		
		GIDSignIn.sharedInstance().clientID = "293065220737-1a2pu3qlchlk127agvgngr02f75ja2ed.apps.googleusercontent.com"
		GIDSignIn.sharedInstance().delegate = self

		
		let apiPlugin = AWSAPIPlugin(modelRegistration: AmplifyModels())
		let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
		do {
		   try Amplify.add(plugin:apiPlugin)
		   try Amplify.add(plugin:dataStorePlugin)
		   try Amplify.configure()
		   print("Initialized Amplify");
		} catch {
		   print("Could not initialize Amplify: \(error)")
		}
		
		return true
	}
	
    @available(iOS 9.0, *)
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
	{
//		print(url, "This is the url alphabetagamma")
//		ApplicationDelegate.shared.application(
//			app,
//			open: url,
//			sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//			annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//		)
		return GIDSignIn.sharedInstance().handle(url)
	}
	

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}


}


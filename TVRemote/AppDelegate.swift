//
//  AppDelegate.swift
//  TVRemote
//
//  Created by Andrey Styskin on 04.06.16.
//  Copyright © 2016 Andrey Styskin. All rights reserved.
//

import UIKit
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    override class func initialize() {
        if self === AppDelegate.self {
            //Инициализация AppMetrica SDK
            YMMYandexMetrica.activateWithApiKey("0f8d5079-806a-4a0d-b730-b69233b64474")
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure SpeechKit lib, this method should be called _before_ any SpeechKit functions.
        // Generate your own app key for this purpose.
//        YSKSpeechKit.sharedInstance().configureWithAPIKey("069b6659-984b-4c5f-880e-aaedcfd84102");
        YSKSpeechKit.sharedInstance().configureWithAPIKey("0b3cac19-a4d0-4240-b4fd-646f15c3d702");
        
        // [OPTIONAL] Set SpeechKit log level, for more options see YSKLogLevel enum.
        YSKSpeechKit.sharedInstance().setLogLevel(YSKLogLevel(YSKLogLevelWarn));
        
        // [OPTIONAL] Set YSKSpeechKit parameters, for all parameters and possible values see documentation.
        YSKSpeechKit.sharedInstance().setParameter(YSKDisableAntimat, withValue: "false");
        
//        window = UIWindow(frame: UIScreen.mainScreen().bounds);
//        
//        let recognizerController = YSKRecognizerViewController(recognizerLanguage: YSKRecognitionLanguageRussian, recognizerModel: YSKRecognitionModelGeneral);
//        let navigationController = UINavigationController(rootViewController: recognizerController);
//        navigationController.navigationBar.translucent = true;
//
//        window?.rootViewController = ViewController();
//        window?.makeKeyAndVisible();

        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


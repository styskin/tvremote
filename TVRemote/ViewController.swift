//
//  ViewController.swift
//  TVRemote
//
//  Created by Andrey Styskin on 04.06.16.
//  Copyright © 2016 Andrey Styskin. All rights reserved.
//

import UIKit



func HTTPsendRequest(request: NSMutableURLRequest,callback: (String, String?) -> Void) {
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request,completionHandler :
        {
            data, response, error in
            if error != nil {
                callback("", (error!.localizedDescription) as String)
            } else {
                callback(NSString(data: data!, encoding: NSUTF8StringEncoding) as! String,nil)
            }
    })
    
    task.resume() //Tasks are called with .resume()
    
}

func HTTPPost(url: String, json : [String : String], callback: (String, String?) -> Void) {
    let jsonData = try? NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions() )
    
    let request = NSMutableURLRequest(URL: NSURL(string: url)!) //To get the URL of the receiver , var URL: NSURL? is used
    request.HTTPMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = jsonData
    HTTPsendRequest(request, callback: callback)
}


class ViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var browser: UIWebView!
    
    var timer = NSTimer()
    var curl = "https://www.yandex.ru"
    var current = "https://www.yandex.ru" as NSString
    
    func checkBrowser() {
        let currentURL : NSString?
        currentURL = browser.request?.URL?.absoluteString
        if (currentURL != nil && currentURL != current) {
            HTTPPost("https://tvremote-1334.appspot.com/tv", json : ["url" : currentURL! as String]) {
//                HTTPPost("http://localhost:8080/tv", json : ["url" : currentURL as String]) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    print(error)
                } else {
                    print("data is : \n\n\n")
                    print(data)
                }
            }
            current = currentURL!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSearchEngine()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.checkBrowser), userInfo: nil, repeats: true)
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSearchEngine(query: String? = nil) {
        var searchEngineURLString = "https://www.yandex.ru"
        var searchEngineURL = NSURL(string: searchEngineURLString)
        if(query != nil) {
            var url = "https://yandex.ru/yandsearch?text=" + query!
            searchEngineURL = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        }
        var searchEngineURLRequest = NSURLRequest(URL: searchEngineURL!)
        browser?.loadRequest(searchEngineURLRequest)
    }
    
    func tabBar(tabBar: UITabBar!, didSelectItem item: UITabBarItem!) {
        switch item.tag  {
        case 0:
            loadSearchEngine()
            break
        case 1:
            browser.goBack()
            break
        case 2:
            // VOICE RECOGNITION
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("speechview") as! YSKRecognizerViewController?
            if (vc != nil) {
                self.presentViewController(vc!, animated: true, completion: nil)
            }
            break
        default:
            loadSearchEngine()
            break
        }
        
    }


}


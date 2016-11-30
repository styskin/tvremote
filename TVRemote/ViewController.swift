//
//  ViewController.swift
//  TVRemote
//
//  Created by Andrey Styskin on 04.06.16.
//  Copyright © 2016 Andrey Styskin. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import YandexMobileMetrica

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
    let deviceid = UIDevice.currentDevice().identifierForVendor!.UUIDString;
    request.setValue(String(format: "device=\"%@\"", deviceid), forHTTPHeaderField: "Cookie")
    request.HTTPBody = jsonData
    HTTPsendRequest(request, callback: callback)
}


class ViewController: UIViewController, UITabBarDelegate, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet weak var browser: UIWebView!
    
    var timer = NSTimer()
    var current = "https://www.yandex.ru" as NSString
//    let server = "https://tvremote-1334.appspot.com"
//    let server = "http://localhost:8989"
    let server = "http://jtvremote.herokuapp.com"
    
    lazy var readerVC: QRCodeReaderViewController = {
        
        let builder = QRCodeViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
            builder.showTorchButton = true
            builder.cancelButtonTitle = "http://jtvremote.herokuapp.com"
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    
    func sendToServer(currentURL : NSString, force: Int) {
        HTTPPost(server + "/tv", json : ["url" : currentURL as String, "force" : String(force)]) {
            (data: String, error: String?) -> Void in
            if error != nil {
                NSLog("Server error: %@", error!)
            } else {
                YMMYandexMetrica.reportEvent("sendToServer", parameters: ["url": data], onFailure: {error in
                    NSLog("DID FAIL REPORT EVENT: %@", data)
                    NSLog("REPORT ERROR: %@", error.localizedDescription)
                })
                NSLog("Server responce: %@", data)
            }
        }
        
    }
    
    func checkBrowser() {
        let currentURL : NSString?
        currentURL = browser.request?.URL?.absoluteString
        if (currentURL != nil && currentURL != current) {
            sendToServer(currentURL!, force: 0)
            current = currentURL!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSearchEngine()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.checkBrowser), userInfo: nil, repeats: true)
                
    }

    override func didReceiveMemoryWarning() {
        YMMYandexMetrica.reportEvent("didReceiveMemoryWarning", onFailure: {error in
            NSLog("DID FAIL REPORT EVENT: %@", "didReceiveMemoryWarning")
            NSLog("REPORT ERROR: %@", error.localizedDescription)
        })
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSearchEngine(query: String? = nil) {
        let searchEngineURLString = "https://www.yandex.ru"
        var searchEngineURL = NSURL(string: searchEngineURLString)
        if(query != nil) {
            let url = "https://yandex.ru/yandsearch?text=" + query!
            searchEngineURL = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        }
        let searchEngineURLRequest = NSURLRequest(URL: searchEngineURL!)
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
            YMMYandexMetrica.reportEvent("voice", onFailure: {error in
                NSLog("DID FAIL REPORT EVENT: %@", "voice")
                NSLog("REPORT ERROR: %@", error.localizedDescription)
            })
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("speechview") as! YSKRecognizerViewController?
            if (vc != nil) {
                self.presentViewController(vc!, animated: true, completion: nil)
            }
            break
        case 3:
            // FORCE ON TV
            sendToServer(current, force: 1)
            break
        case 4:
            YMMYandexMetrica.reportEvent("openqr", onFailure: {error in
                NSLog("DID FAIL REPORT EVENT: %@", "openqr")
                NSLog("REPORT ERROR: %@", error.localizedDescription)
            })
            // Open QR reader
            if QRCodeReader.supportsMetadataObjectTypes() {
                readerVC.modalPresentationStyle = .FormSheet
                readerVC.delegate               = self
                
                readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                    if let result = result {
                        print("Completion with result: \(result.value) of type \(result.metadataType)")
                    }
                }
                
                presentViewController(readerVC, animated: true, completion: nil)
            } else {
                // USE manual code input
                let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                
//                HTTPPost(server + "/register?tv=1480457098427322.0", json: [:]) {
//                    (data: String, error: String?) -> Void in
//                    if error != nil {
//                        NSLog("Error on post qr% %@", error!)
//                    } else {
//                        NSLog("Send qr% %@", data)
//                    }
//                }
            }
            break
        default:
            loadSearchEngine()
            break
        }
        
    }
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismissViewControllerAnimated(true) { [weak self] in
            HTTPPost(self!.server + "/register?tv=" + result.value, json: [:]) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    NSLog("Error on post qr% %@", error!)
                } else {
                    NSLog("Send qr% %@", data)
                }
            }

        }
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}


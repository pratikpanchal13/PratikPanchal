//
//  Webservice.swift
//  PratikPanchal
//
//  Created by Pratik on 19/09/17.
//  Copyright © 2017 Pratik. All rights reserved.
//


import Foundation
import Alamofire
import UIKit
import SwiftyJSON
import SystemConfiguration
import MBProgressHUD


class Webservice {
        
    //check internet utility
    class func isNetworkAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}

extension Webservice{
    
    //-------------------------------------------------
    //MARK :- API Call GET
    //-------------------------------------------------
    class func GET(_ url: String,
                   param: [String: Any]?,
                   controller: UIViewController,
                   header : [String: String]?,
                   callSilently : Bool = false,
                   successBlock: @escaping (_ response: JSON) -> Void,
                   failureBlock: @escaping (_ error: Error? , _ isTimeOut: Bool) -> Void) {
        
        // Internet is connected
        if isNetworkAvailable() {
            
            if !callSilently {
                MBProgressHUD.showAdded(to: (UIApplication.shared.delegate?.window!)! , animated: true)
            }
            
            Alamofire.request(url, method: .get, parameters: param, encoding: JSONEncoding(options: []), headers: header).responseJSON(completionHandler: { (response) in
                
                
                if !callSilently{
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: ((UIApplication.shared.delegate?.window)!)!, animated: true)
                    }
                }
                
                //print("---- GET REQUEST URL RESPONSE : \(url)\n\(response.result)")
                //print(response.timeline)
                
                switch response.result {
                case .success:
                    
                    if !callSilently{
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: ((UIApplication.shared.delegate?.window)!)!, animated: true)
                        }
                    }
                    
                    if let aJSON = response.result.value {
                        
                        let json = JSON(aJSON)
                        print("---- GET SUCCESS RESPONSE : \(json)")
                        successBlock(json)
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    
                    if !callSilently{
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: ((UIApplication.shared.delegate?.window)!)!, animated: true)
                        }
                    }
                    
                    if (error as NSError).code == -1001 {
                        print("The request timed out. Pelase try after again.")
                        failureBlock(error, true)
                    } else {
                        print("Somthin went Wrong.")
                        failureBlock(error, false)
                    }
                    break
                }
                
            })
            
        }
        else{
            print("InternetNotAvailable.")
            let aErrorConnection = NSError(domain: "InternetNotAvailable", code: 0456, userInfo: nil)
            failureBlock(aErrorConnection as Error , false)
        }
    }
    
    
    
}


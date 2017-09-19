
//  Utility.swift
//  PratikPanchal
//
//  Created by Pratik on 19/09/17.
//  Copyright © 2017 Pratik. All rights reserved.
//

import Foundation
import UIKit

class Utility : NSObject {
    
    //MARK:- Get DataBase Path
    class func getPath(_ fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    //MARK:- Copy DataBase
    class func copyFile(_ fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        print("Document Path is \(dbPath)")
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let error1 as NSError {
                error = error1
            }
            if (error != nil) {
                print("Error Occured")
                
            } else {
                print("Your database copy successfully")
            }
            
        }
    }
    
}

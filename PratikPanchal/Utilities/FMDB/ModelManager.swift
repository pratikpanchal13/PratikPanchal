//
//  ModelManager.swift
//  PratikPanchal
//
//  Created by Pratik on 19/09/17.
//  Copyright © 2017 Pratik. All rights reserved.
//

import Foundation

import UIKit
import FMDB


// Create Shared Instance Class
let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Utility.getPath("PratikPanchal.db"))
        }
        return sharedInstance
    }
    
    
    //MARK:- Insert Data Into FMDB
    func addData(_ info: UserModel) -> Bool {
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO User(login,avatar_url) VALUES (?, ?)", withArgumentsIn: [info.login ?? 0, info.avatar_url ?? 0])
        sharedInstance.database!.close()
        
        return isInserted
    }

    //MARK:- Delete Data From FMDB
    func deleteData(_ info: String) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM User WHERE id=?", withArgumentsIn: [info])
        sharedInstance.database!.commit()
        sharedInstance.database!.close()
        return isDeleted
    }
    
    
    //MARK:- Delete All Data From FMDB
    func deletaAllData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM User", withArgumentsIn: [])
        sharedInstance.database!.commit()
        sharedInstance.database!.close()
        return isDeleted
    }
    
    
    //MARK:- Get All Data From FMDB
    func getAllData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM User", withArgumentsIn: [])
        let marrArrayInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                //let info : UserModel = UserModel()
                //info.login = resultSet.string(forColumn: "login")
                //info.avatar_url = resultSet.string(forColumn: "avatar_url")
                
                var dct = [String : Any]()
                dct["id"] = resultSet.string(forColumn: "id")
                dct["login"] = resultSet.string(forColumn: "login")
                dct["avatar_url"] = resultSet.string(forColumn: "avatar_url")
                marrArrayInfo.add(dct)
                //print("DATABAS RECORD : ",marrArrayInfo)
            }
        }
        sharedInstance.database!.close()
        return marrArrayInfo
    }
}

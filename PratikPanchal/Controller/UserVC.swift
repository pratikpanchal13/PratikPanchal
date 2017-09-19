//
//  UserVC.swift
//  PratikPanchal
//
//  Created by Pratik on 19/09/17.
//  Copyright © 2017 Pratik. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class UserVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{
    
    
    var selectedPaths=Set<IndexPath>()
    
    
    //MARK: outlets & Variables
    
    @IBOutlet var tblUserData: UITableView!
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet weak var imgSearch: UIImageView!
    
    var objModel = [PKModel]()
    var mutArray : [[String : String]] = []
    var searchedArray:[[String : String]] = []
    var refreshControl : UIRefreshControl!
    
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()      // Initial SetUp
    }
    
    //MARK:- initial SetUp
    func initialSetup()
    {
        if UserDefaults.standard.value(forKey: "isLoadFirst") == nil {
            self.getAPICall()    // Get Data from API Call Only Once
            UserDefaults.standard.setValue("load", forKey: "isLoadFirst")
        }else{
            self.getUserData()  // Get Data from Local Storage
        }
        self.txtSearch.setLeftPaddingPoints(30)
        pullToRefresh()
        txtSearch.addTarget(self, action: #selector(searchByUser(_ :)), for: .editingChanged)
        
    }
    
    //MARK:- Pull To Refresh
    func pullToRefresh()
    {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refreshControl.addTarget(self, action:#selector(UserVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        tblUserData.addSubview(refreshControl)
    }
    
    //MARK:- Search Data
    func searchByUser(_ textfield:UITextField) {
        
        if textfield.text?.characters.count != 0 {
            searchedArray.removeAll()
            searchedArray = mutArray.filter { ($0["login"]?.contains(textfield.text!))! }
        }else{
            searchedArray = mutArray
        }
        tblUserData.reloadData()
    }
    
    //MARK:- Pull TO Refresh
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        let isDeleteALlData =    ModelManager.getInstance().deletaAllData()
        if isDeleteALlData
        {
            self.getAPICall()
            self.getUserData()
            self.tblUserData.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : cellUser = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath) as! cellUser
        
        let aDic = searchedArray[indexPath.row]
        cell.lblUserName.text = aDic["login"]
        let imgURL = aDic["avatar_url"]
        cell.imgUserProfile.sd_setImage(with: URL(string: imgURL!), placeholderImage: UIImage(named: "Placeholder"))
        cell.imgUserProfile.layer.cornerRadius = cell.imgUserProfile.frame.size.width/2
        cell.imgUserProfile.clipsToBounds = true
        
        var image = UIImage(named: "unCheck")
        if self.selectedPaths.contains(indexPath) {
            image = UIImage(named: "Check")
        }
        cell.btnCheckUncheck.setImage(image, for: .normal)
        cell.btnCheckUncheck.tag = indexPath.row
        cell.btnCheckUncheck.addTarget(self, action: #selector(UserVC.btnCheckUncheck(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    
    func btnCheckUncheck(sender : AnyObject) {
    
        let buttonPosition:CGPoint = sender.convert(.zero, to:tblUserData)
        let indexPath = tblUserData.indexPathForRow(at: buttonPosition)
        
        let cell:cellUser = tblUserData.cellForRow(at: indexPath!) as! cellUser

        var image = UIImage(named: "Check")
        if self.selectedPaths.contains(indexPath!) {
            image = UIImage(named: "unCheck")
            self.selectedPaths.remove(indexPath!)
        } else {
            self.selectedPaths.insert(indexPath!)
        }
        cell.btnCheckUncheck.setImage(image, for: .normal)
        
    }
    
    
    // For Swipe To Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            var dct = self.searchedArray[indexPath.row ]  as [String : Any]
            let deletdID = dct["id"] as! String
            let isDelete : Bool =  ModelManager.getInstance().deleteData(deletdID)
            if isDelete{
                self.txtSearch.text = ""                
                self.getUserData()
            }
        }
    }
}

//MARK:- Local Storage Using FMDB (Local Data Storage , Delete Data Storage Using FMDB)
extension UserVC{

    //MARK: - Get All User Data From Local Using FMDB
    func getUserData()
    {
        mutArray = ModelManager.getInstance().getAllData() as! [[String : String]]
        searchedArray = mutArray
        tblUserData.reloadData()
    }
    
    //MARK:-  Save Local Data Using FMDB
    func SaveDataUsingFMDBLocal(userData : [[String : Any]])
    {
        for dctUserInfo in userData
        {
            let dctData = dctUserInfo as [String : Any ]
            let info: UserModel = UserModel()
            info.id = dctData["id"] as? String
            info.login = dctData["login"] as? String
            info.avatar_url = dctData["avatar_url"] as? String
            
            let isInserted = ModelManager.getInstance().addData(info)
            if isInserted {
                //                print("Record Inserted successfully")
            } else {
                print("Error")
            }
        }
        self.getUserData()
    }
}

//MARK:- API Calling For Getting User Data
extension UserVC
{
    func getAPICall()
    {
        let apiURL = "https://api.github.com/users?since"
//        let apiURL = "https://api.github.com/user/repos?page=1&per_page=10"
        
        
        Webservice.GET(apiURL, param: nil, controller: self, header: nil, successBlock: { (response) in
            
            let arrayData = response.arrayObject as! [[String : Any]]
            self.SaveDataUsingFMDBLocal(userData: arrayData)
            self.tblUserData.reloadData()
            
        }) { (error ,TimeOot) in
            print("Error")
        }
    }
}


//MARK:- Custome Tableview Cell
class cellUser  : UITableViewCell
{
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var btnCheckUncheck: UIButton!
    
}

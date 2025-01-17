//
//  SearchScreenTableViewController.swift
//  BookSwap
//
//  Created by RV on 12/1/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import CoreData

class SearchScreenTableViewController: UITableViewController {

    
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let progressBarInstance = SVProgressHUDClass.shared
    
    var selectedUser : String?
    
    let USER_NAME = "UserName"
    let RATING = "Rating"
    let EMAIL = "Email"
    
    
    
    var searchResult : Dictionary<Int, Dictionary<String, Any>>  = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //loadResult(search: "Mr. One")
        
        tableView.rowHeight = 80
        self.hideKeyboardWhenTappedAround()
        
        progressBarInstance.displayMessage(message: "Search by Username or Email")

        
    }
    
    
    //MARK: Search User
    func loadResult(search: String){
        
        searchResult.removeAll()
        databaseIstance.getListOfSearchFriends(usersEmail: authInstance.getCurrentUserEmail(), searchText: search) { (dict) in
            
            var index = 0
            
            for (_, data) in dict {
                
                self.searchResult[index] = data
                
                index += 1
            }
            
            print("This is Dict: \(self.searchResult as AnyObject)")
            
            self.tableView.reloadData()
            self.progressBarInstance.dismissProgressBar()
        }
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return searchResult.count
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = (searchResult[indexPath.row]![EMAIL] as! String)
        
        performSegue(withIdentifier: "toProfileScreen", sender: self)
        
        //to create click animation
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriendCell", for: indexPath) as! SearchScreenTableViewCell
        
        cell.addButton.isEnabled = true
        cell.addButton.setTitle("Add", for: .normal)
        
        cell.userNameLbl?.text = (searchResult[indexPath.row]![USER_NAME]! as! String)
        cell.ratingLbl?.text = ("\(searchResult[indexPath.row]![RATING]!)")
        cell.emailLbl?.text = (searchResult[indexPath.row]![EMAIL]! as! String)
        
        //checkIfFriends function checks if they are friends
        if (checkIfFriend(email: searchResult[indexPath.row]![EMAIL]! as! String)) {
            
            //if they are friends, hide the 'Add' button
            cell.addButton.isHidden = true
        } else {
            
            //if they are not, unhide the 'Add' button
            cell.addButton.isHidden = false
        }
        //cell.addButton
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileScreen" {
            let destinationVC = segue.destination as! ProfileScreen
            destinationVC.usersProfile = selectedUser
        }
    }
    
    func checkIfFriend (email : String) -> Bool {

        let request: NSFetchRequest<Friends> = Friends.fetchRequest()
        let predicate = NSPredicate(format: "friendsEmail == %@", email)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let count = try CoreDataClass.sharedCoreData.getContext().count(for: request)
            if(count == 0){
                // no matching object
                return false
            }
            else{
                // at least one matching object exists
                print("Match Found!")
                return true
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return false
        }
    }

    
}


extension SearchScreenTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       //here goes your code
        
        progressBarInstance.displayProgressBar()
        self.loadResult(search: searchBar.text!)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            //loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            //loadItems()
            //tableView.reloadData()
        }
    }
    
}

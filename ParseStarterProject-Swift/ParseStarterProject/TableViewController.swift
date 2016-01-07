//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Chris Wong on 2015-12-14.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {

    var usernames = [String]()
    var userids = [String]()
    var isFollowing = [String:Bool]()
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            
            if let users = objects {
                
                self.usernames.removeAll(keepCapacity: true)
                self.userids.removeAll(keepCapacity: true)
                self.isFollowing.removeAll(keepCapacity: true)
                
                for object in users {
                    //cast object to PFUser
                    if let user = object as? PFUser {
                        
                        // dont include current user
                        if PFUser.currentUser()?.objectId != user.objectId {
                            self.usernames.append(user.username!)
                            self.userids.append(user.objectId!)
                            
                            //check user is being followed by current user
                            let query = PFQuery(className: "followers")
                            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                            query.whereKey("following", equalTo: user.objectId!)
                            // run query returns an array of anyobjects
                            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                if let objects = objects {
                                    
                                    // if object count > 0, which mean follower found
                                    if objects.count > 0 {
                                        
                                        self.isFollowing[user.objectId!] = true
                                    }
                                    else {
                                        self.isFollowing[user.objectId!] = false
                                    }
                                    
                                }
                                // check isFollowing count equals usernames
                                if self.isFollowing.count == self.usernames.count{
                                    // reload data
                                    self.tableView.reloadData()
                                    //print("reload")
                                    // remove refreshing
                                    self.refresher.endRefreshing()
                                    //print("refreshin")
                                    //print(self.isFollowing)
                                    
                                }
                                
                            })
                        }
                        
                    }
                }
                
            }
            
            //print(self.usernames)
            //print(self.userids)
            
        })

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // Refresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        // run the refresh function when the pull to refresh is initiated
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        // Use this because its overlaps the cells
        self.tableView.insertSubview(refresher, atIndex: 0)
        
        
        //self.tableView.addSubview(refresher)
        
        refresh()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

         //Configure the cell... set the identifier in the table to cell
        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark

        }
        
        return cell
    }

    // when user touches the cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
    
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!

        let followedObjectId = userids[indexPath.row]
        
        if isFollowing[followedObjectId] == false {
            
            isFollowing[followedObjectId] = true
            
            // follow
            let following = PFObject(className: "followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()?.objectId
            following.saveInBackground()
            
            // add check mark to cell
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark

            
        }
        else {
            //unfollow

            isFollowing[followedObjectId] = false
            
            // remove check mark to cell
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            //check user is being followed by current user
            let query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects {
                   
                    for object in objects {
                        object.deleteInBackground()
                    }
                    
                }
                
            })

            
        }
        
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

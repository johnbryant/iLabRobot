//
//  ConnectViewController.swift
//  iLabRobot
//
//  Created by JohnBryant on 6/2/16.
//  Copyright © 2016 JohnBryant. All rights reserved.
//

import UIKit

class ConnecViewController: UITableViewController {
    
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    var isConnected = false
    var pairRobot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "连接控制"
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        if !pairRobot {
            connectButton.title = "搜索"
        } else {
            if !isConnected {
                connectButton.title = "连接"
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pairRobot {
            return 1
        } else {
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("connectCell", forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    @IBAction func setButton(sender: AnyObject) {
        if !pairRobot {
            print("搜索设备...")
        } else {
            if !isConnected {
                print("连接设备")
            } else {
                print("设置")
            }
        }
    }
    
}

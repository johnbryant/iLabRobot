//
//  ConnectViewController.swift
//  iLabRobot
//
//  Created by JohnBryant on 6/2/16.
//  Copyright © 2016 JohnBryant. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConnecViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    var isConnected = false
    var pairRobot = false
    
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var writeString: CBCharacteristic!
    var deviceList:NSMutableArray = NSMutableArray()
    
    let kServiceUUID = [CBUUID(string:"FFE0")]
    let kCharacteristicUUID = [CBUUID(string:"FFE1")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "连接控制"
        self.tableView.tableFooterView = UIView()
        
        self.manager = CBCentralManager(delegate: self, queue: nil)
        
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
        return self.deviceList.count
        
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
    
    
    // 检查运行这个App的设备是不是支持BLE
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:

            self.manager.scanForPeripheralsWithServices(kServiceUUID, options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])

            print("蓝牙已经打开")
        case .Unauthorized:
            print("无使用权限")
        case .PoweredOff:
            print("蓝牙已经关闭")
        default:
            print("中央管理器没有改变状态")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral")
        if !self.deviceList.containsObject(peripheral) {
            self.deviceList.addObject(peripheral)
        }
        self.tableView.reloadData()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
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

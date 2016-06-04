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
    // 设置延迟队列
    let workingQueue = dispatch_queue_create("my_queue", nil)
    var indicatorView: MONActivityIndicatorView!
    
    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    var noDeviceStateLabel = UILabel()
    var deviceNameText = "iLabRobotRX0001"
    
    var isConnected = false {
        didSet {
            if isConnected {
                connectButton.title = "断开连接"
            } else {
                if pairRobot {
                    connectButton.title = "连接"
                }
            }
        }
    }
    var pairRobot: Bool = false {
        didSet {
            if pairRobot {
                noDeviceStateLabel.hidden = true
                if !isConnected {
                    connectButton.title = "连接"
                }
            } else {
                noDeviceStateLabel.hidden = false
                connectButton.title = "搜索"
            }
        }
    }
    
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
        noDeviceStateLabel.text = "没有设备连接"
        noDeviceStateLabel.textColor = UIColor.grayColor()
        noDeviceStateLabel.frame = CGRectMake(110, 200, 110, 20)
        self.view.addSubview(noDeviceStateLabel)
        
        self.manager = CBCentralManager(delegate: self, queue: nil)
        
        indicatorView = MONActivityIndicatorView()
        indicatorView.center = self.view.center;
        indicatorView.center.y -= 40
        indicatorView.center.x -= 60
        self.view.addSubview(indicatorView)
        
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
        let deviceName = cell.viewWithTag(1001) as! UILabel
        let deviceState = cell.viewWithTag(1002) as! UILabel
        if isConnected {
            cell.backgroundColor = UIColor(red: 31/255, green: 202/255, blue: 255/255, alpha: 1)
            deviceName.text = deviceNameText
            deviceState.text = "已连接"
        } else {
            cell.backgroundColor = UIColor(red: 225/255, green: 31/255, blue: 62/255, alpha: 0.73)
            deviceName.text = deviceNameText
            deviceState.text = "未连接"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if self.isConnected {
            
        }
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
            self.indicatorView.startAnimating()
            dispatch_async(workingQueue) {
                NSThread.sleepForTimeInterval(3)
                dispatch_async(dispatch_get_main_queue()) {
                    self.pairRobot = true
                    self.indicatorView.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        } else {
            if !isConnected {
                self.indicatorView.startAnimating()
                dispatch_async(workingQueue) {
                    NSThread.sleepForTimeInterval(4)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isConnected = true
                        self.indicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }

                print("连接设备")
            } else {
                self.indicatorView.startAnimating()
                dispatch_async(workingQueue) {
                    NSThread.sleepForTimeInterval(4)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.isConnected = false
                        self.indicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }

                print("断开连接")
            }
        }
    }
    
    
}

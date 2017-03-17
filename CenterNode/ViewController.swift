//
//  ViewController.swift
//  CenterNode
//
//  Created by Tong Yu on 2/20/17.
//  Copyright © 2017 Tong Yu. All rights reserved.
//

// TODO: 能不能让它后台一直保持正常运行？而不是降低频率

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate
{
    
    var myCentralManager = CBCentralManager()
    var peripherals:[CBPeripheral] = []
    var myPeripheral = CBPeripheralManager()
    
    var packetProcessing1 = PacketProcessing()
    
    var timer1 = Timer()  // 还是要定时重启扫描，要不然发完ACK后不知道relaynode停止了没
    var timer2 = Timer()


    var scan = false
    var iMessage = false
    
    var alarmFieldStr = Array<String>()
    
    
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var textField2: NSTextField!
    @IBOutlet weak var textField4: NSTextField!
    @IBOutlet weak var textField5: NSTextField! // Reserved

    @IBOutlet weak var tableView1: NSTableView!
    @IBOutlet weak var tableView2: NSTableView!
    
    
    @IBAction func button1(_ sender: NSButton)
    {
        if sender.state == NSOnState
        {
            sender.title = "Running"
            textField1.stringValue = "Scannning"
            textField2.stringValue = ""
//            myCentralManager.scanForPeripherals(withServices: nil, options: nil ) // 没看出来和下面那句话的有何不同，表现都一样。
            myCentralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true] )
            scan = true
            timer2 = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timer2Action), userInfo: nil, repeats: true)
        } else
        {
            sender.title = "Start"
            textField1.stringValue = ""
            myCentralManager.stopScan()
            timer2.invalidate()
        }
    }
    
    
    func timer1Action()
    {
        packetProcessing1.counterIncrease()
        tableView1.reloadData()
    }
    
    
    func timer2Action()
    {
        if packetProcessing1.advList.isEmpty
        {
            if myPeripheral.isAdvertising
            {
                textField2.stringValue = "Not Advertising"
                myPeripheral.stopAdvertising()
            }else
            {
                return
            }
        }else
        {
            let advStr = packetProcessing1.advList.removeFirst()
            myPeripheral.startAdvertising([CBAdvertisementDataLocalNameKey: advStr])
            textField2.stringValue = "Is Advertising"
        }
    }
    
    
    @IBAction func button2(_ sender: NSButton)
    {
        let initString = "TONG00"    //  relay node一看第一位是30，那就是init command
        for tempStr in packetProcessing1.advList
        {
            if tempStr == initString
            {
                return
            }
        }
        
        packetProcessing1.advList.append(initString)
        packetProcessing1.advList.append(initString)
        packetProcessing1.advList.append(initString)
        packetProcessing1.advList.append(initString)    // 延长广播init packet 的时间
    }
    
    
    @IBAction func button3(_ sender: NSButton)
    {
        if sender.title == "Add iMessage ID"
        {
            if textField4.stringValue.isEmpty
            {
                return
            }
            textField4.isEditable = false
//            textField4.backgroundColor = NSColor.labelColor
            sender.title = "Remove iMessage ID"
        }else
        {
            textField4.isEditable = true
            sender.title = "Add iMessage ID"
        }
    }

    
    @IBAction func button5(_ sender: NSButton)
    {
        alarmFieldStr.removeAll()
        tableView2.reloadData()
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        //if let manufdata = advertisementData["kCBAdvDataManufacturerData"]
        guard let manufdata = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else
        {
            return
        } //as? Data 啥意思来着？

        print("dahaha")
        
        let alarmEvent = packetProcessing1.packetCheck(manufacturerData: manufdata)
        
        if alarmEvent != nil
        {
            for tempStr in alarmFieldStr
            {
                if tempStr == alarmEvent
                {
                    return
                }
            }
            
            alarmFieldStr.append(alarmEvent!)
            
            if !textField4.isEditable
            {
                let task = Process()
                task.launchPath = Bundle.main.path(forResource: "osascript", ofType: nil)
                let scriptPath = Bundle.main.path(forResource: "send_iMessage", ofType: "scpt")
                task.arguments = [scriptPath!, textField4.stringValue, alarmEvent!]
                task.launch()
            }
        }
        
        tableView1.reloadData() // 不晓得回一次过来几个peripheral啊，如果一次过来好几个，那么这个table就要每次都refresh
        tableView2.reloadData()
    }


    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        if let hahaha = error
        {
            print("\(hahaha)")
        }else{
            print("advertising with no error")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
        myPeripheral     = CBPeripheralManager(delegate: self, queue: nil)
        //myCentralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.main)
        timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timer1Action), userInfo: nil, repeats: true)
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        
        switch central.state
        {
        case .poweredOn: textField1.stringValue = "Central State: poweredOn" // 当poweredOn时才能下达指令
            
        case .poweredOff: textField1.stringValue = "Please Turn On Bluetooth"
            
        case .resetting: textField1.stringValue = "Central State: Resetting"
            
        case .unauthorized: textField1.stringValue = "Central State: Unauthorized"
            
        case .unknown: textField1.stringValue = "Central State: Unknown"
            
        case .unsupported: textField1.stringValue = "Central State: Unsupported"
        }
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        switch peripheral.state{
            
        case .poweredOn: textField2.stringValue = "Peripheral State: poweredOn" // 当poweredOn时才能下达指令
            
        case .poweredOff: textField2.stringValue = "Please Turn On Bluetooth!"
            
        case .resetting: textField2.stringValue = "Peripheral State: Resetting"
            
        case .unauthorized: textField2.stringValue = "Peripheral State: Unauthorized"
            
        case .unknown: textField2.stringValue = "Peripheral State: Unknown"
            
        case .unsupported: textField2.stringValue = "Peripheral State: Unsupported"
        }
    }
}


extension ViewController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        if tableView == tableView1
        {
            return packetProcessing1.deviceList.count
        }else
        {
            return alarmFieldStr.count
        }
    }
}

extension ViewController: NSTableViewDelegate
{
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        if tableView == tableView1
        {
            var identifierStr = ""
            identifierStr = tableColumn!.identifier
            
            if packetProcessing1.deviceList.count == 0
            {
                return nil
            }
            
            let key   = Array(packetProcessing1.deviceList.keys).sorted(by: <)[row]
            //        var value = Array(packetProcessing1.deviceList.values)[row]
            
            
            if identifierStr == "Number"
            {
                return key
                
            }else if identifierStr == "Level"
            {
                return packetProcessing1.deviceList[key]![0]
                
            }else if identifierStr == "Count"
            {
                return packetProcessing1.deviceList[key]![1]
                
            }
        }else
        {
            return alarmFieldStr.reversed()[row]
        }
        
        return nil
    }
}



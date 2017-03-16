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
    
    var timer1 = Timer()  // 还是要定时重启扫描，要不然到了两个小时也收不到self_report? p
    var timer2 = Timer()
    var timer3 = Timer()

    
    var scan = false
    
    
    
    
    
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var textField2: NSTextField!
    @IBOutlet weak var textField3: NSTextField!
    @IBOutlet weak var textField4: NSTextField!
    @IBOutlet weak var textField5: NSTextField!

    @IBOutlet weak var tableView1: NSTableView!

    
    
    @IBAction func button1(_ sender: NSButton)
    {
        if sender.state == NSOnState {
            updateStatusLabel("Scannning")
            myCentralManager.scanForPeripherals(withServices: nil, options: nil )
            scan = true
            timer1 = Timer.scheduledTimer(timeInterval: 5000, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            timer2 = Timer.scheduledTimer(timeInterval: 4999, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            // timer 最后去掉
            timer3 = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timer3Action), userInfo: nil, repeats: true)
        } else {
            timer1.invalidate()
        }
    }
    
    func timer3Action()
    {
        packetProcessing1.counterIncrease()
        tableView1.reloadData()
    }
    
    
    // called every time interval from the timer
    func timerAction()
    {
        
        if scan == false {
            updateStatusLabel("Scannning")
            myCentralManager.scanForPeripherals(withServices: nil, options: nil )
            scan = true
            timer2 = Timer.scheduledTimer(timeInterval: 4999, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            
        } else {
            updateStatusLabel("Not Scanning")
            myCentralManager.stopScan()
            scan = false
        }
        
    }
    
    
    
    @IBAction func button2(_ sender: NSButton)
    {
        if sender.state == 1 {
            
            updateStatusLabel2("Advertising") // 频率 about 5 times per second, 发送ACK时持续2秒就够了，发送init指令时要持续6秒吧。取决于scan window
            
//            let catCharacters:[Character] = ["31", "2", "3", "4"]
//            let catString = String(catCharacters)
//            let num = 32
//            let str = String(num, radix: 16)
//            let d1 = 21
//            let b1 = String(d1, radix: 2)
//            let a = UnicodeScalar(46)
//            let c = String(a)
//            let s = "\u{41}"
//            let n: UInt8 = 0x35
            
            let haha = String(format:"%X", 0)   //hex 30
            let haha1 = String(format:"%X", 1)
            let haha2 = String(format:"%X", 9)  //hex 39
            let hex_a = ":"
            let hex_b = ";"
            let hex_c = "<"
            let hex_d = "="
            let hex_e = ">"
            let hex_f = "?"
            var advString: String = "TONG"
            advString = advString + haha + haha1 + haha2 + hex_a + hex_b + hex_c + hex_d + hex_e + hex_f
            
            
            let utf8 : [UInt8] = [0xE2, 0x82, 0xAC, 0]
            let str = NSString(bytes: utf8, length: utf8.count, encoding: String.Encoding.utf8.rawValue)
            myPeripheral.startAdvertising([CBAdvertisementDataLocalNameKey: str!])
            
//            // create an array of bytes to send
//            var byteArray = [UInt8]()
//            byteArray.append(0b11011110); // 'DE'
//            byteArray.append(0b10101101); // 'AD'
//            // convert that array into an NSData object
//            let manufacturerData = NSData(bytes: byteArray,length: byteArray.count)
//            // build the bundle of data
//            let dataToBeAdvertised:[String: AnyObject?] = [CBAdvertisementDataLocalNameKey : manufacturerData]
//            myPeripheral.startAdvertising(dataToBeAdvertised)
            
            
            
        } else
        {
            if myPeripheral.isAdvertising
            {
                print("was Advertising")
            }
            updateStatusLabel2("Not Advertising")
            myPeripheral.stopAdvertising()
        }
        
    }
    
    
    @IBAction func button3(_ sender: NSButton)
    {
        textField5.stringValue = textField4.stringValue
        textField4.stringValue = ""
    }
    
    @IBAction func button4(_ sender: NSButton)
    {
//        NSWorkspace.shared().launchApplication("/Applications/Send_iMessages.app {"cloud19930930@gmail.com","Message"}")

    }

    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        
        switch central.state
        {
        case .poweredOn: updateStatusLabel("Central State: poweredOn") // 当poweredOn时才能下达指令
            
        case .poweredOff: updateStatusLabel("Central State: PoweredOFF. Please Turn On Bluetooth!")
            
        case .resetting: updateStatusLabel("Central State: Resetting")
            
        case .unauthorized: updateStatusLabel("Central State: Unauthorized")
            
        case .unknown: updateStatusLabel("Central State: Unknown")
            
        case .unsupported: updateStatusLabel("Central State: Unsupported")
            
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        switch peripheral.state{
            
        case .poweredOn: updateStatusLabel2("Peripheral State: poweredOn") // 当poweredOn时才能下达指令
            
        case .poweredOff: updateStatusLabel2("Peripheral State: PoweredOFF. Please Turn On Bluetooth!")
            
        case .resetting: updateStatusLabel2("Peripheral State: Resetting")
            
        case .unauthorized: updateStatusLabel2("Peripheral State: Unauthorized")
            
        case .unknown: updateStatusLabel2("Peripheral State: Unknown")
            
        case .unsupported: updateStatusLabel2("Peripheral State: Unsupported")
            
        }
    }
    
    
    func updateStatusLabel(_ passedString: String )
    {
        textField1.stringValue = passedString
    }
    
    func updateStatusLabel2(_ passedString: String )
    {
        textField2.stringValue = passedString
    }
    
    // 这部分可以不放在controller里，详见github上下载的例子
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        
        //if let manufdata = advertisementData["kCBAdvDataManufacturerData"]
        guard let manufdata = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            else
        {
            return
        } //as? Data 啥意思来着？

        packetProcessing1.packetCheck(manufacturerData: manufdata)
    }


    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        if let hahaha = error
        {
            print("silly bum \(hahaha)")
        }else{
            print("advertising with no error")
        }
    }
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        packetProcessing1.deviceList[4] = [3,2]
//        packetProcessing1.deviceList[1] = [3,0]
//        packetProcessing1.deviceList[2] = [3,9]
//        packetProcessing1.deviceList[3] = [2,1]

        myCentralManager = CBCentralManager(delegate: self, queue: nil)
//        myCentralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.main)
        myPeripheral = CBPeripheralManager(delegate: self, queue: nil)
        
        textField3.stringValue = "fdsafdsafdsafasdfsadfdsafdsafasdffdsafd \n safasdfdsafadsfasfdsafdasdsafdasfdas"
    }
    
    override var representedObject: Any?
        {
        didSet{
            // Update the view, if already loaded.
        }
    }
}

extension ViewController: NSTableViewDataSource
{
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return packetProcessing1.deviceList.count
    }
    
}

extension ViewController: NSTableViewDelegate
{
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
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
        
        return nil
    }
}



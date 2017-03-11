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

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    var myCentralManager = CBCentralManager()
    var peripherals:[CBPeripheral] = []
    var myPeripheral = CBPeripheralManager()
    
    var timer1 = Timer()  // 还是要定时重启扫描，要不然到了两个小时也收不到self_report
    var timer2 = Timer()

    
    var scan = false
    
    var packetProcessing1 = PacketProcessing()
    
    
    
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var textField2: NSTextField!
    @IBOutlet weak var textField3: NSTextField!
    @IBOutlet weak var textField4: NSTextField!
    
    
    @IBAction func button1(_ sender: NSButton) {
        if sender.state == NSOnState {
            updateStatusLabel("Scannning")
            myCentralManager.scanForPeripherals(withServices: nil, options: nil )
            scan = true
            timer1 = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            timer2 = Timer.scheduledTimer(timeInterval: 9, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
        } else {
            timer1.invalidate()
        }
    }
    
    
    
    // called every time interval from the timer
    func timerAction() {
        
        if scan == false {
            updateStatusLabel("Scannning")
            myCentralManager.scanForPeripherals(withServices: nil, options: nil )
            scan = true
            timer2 = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            
        } else {
            updateStatusLabel("Not Scanning")
            myCentralManager.stopScan()
            scan = false
        }
        
    }
    
    
    
    @IBAction func button2(_ sender: NSButton) {
        if sender.state == 1 {
            
            updateStatusLabel2("Advertising")
            let catCharacters: [Character] = ["T", "O", "N", "G"]
            // TODO: 字母和int不嗯呢个共存啊

            let catString = String(catCharacters)

            myPeripheral.startAdvertising([CBAdvertisementDataLocalNameKey: catString]) // worked // 就先播报名字吧，这样packet还短。单片机怎么过滤信息呢？
            
        } else {
            if myPeripheral.isAdvertising {
                print("was Advertising")
            }
            updateStatusLabel2("Not Advertising")
            myPeripheral.stopAdvertising()
        }
        
    }
    
    
    @IBAction func button3(_ sender: NSButton) {
        
//        NSWorkspace.shared().launchApplication("/Applications/Send_iMessages.app {"cloud19930930@gmail.com","Message"}")
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state{
            
        case .poweredOn: updateStatusLabel("Central State: poweredOn") // 当poweredOn时才能下达指令
            
        case .poweredOff: updateStatusLabel("Central State: PoweredOFF. Please Turn On Bluetooth!")
            
        case .resetting: updateStatusLabel("Central State: Resetting")
            
        case .unauthorized: updateStatusLabel("Central State: Unauthorized")
            
        case .unknown: updateStatusLabel("Central State: Unknown")
            
        case .unsupported: updateStatusLabel("Central State: Unsupported")
            
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state{
            
        case .poweredOn: updateStatusLabel2("Peripheral State: poweredOn") // 当poweredOn时才能下达指令
            
        case .poweredOff: updateStatusLabel2("Peripheral State: PoweredOFF. Please Turn On Bluetooth!")
            
        case .resetting: updateStatusLabel2("Peripheral State: Resetting")
            
        case .unauthorized: updateStatusLabel2("Peripheral State: Unauthorized")
            
        case .unknown: updateStatusLabel2("Peripheral State: Unknown")
            
        case .unsupported: updateStatusLabel2("Peripheral State: Unsupported")
            
        }
        
    }
    
    
    func updateStatusLabel(_ passedString: String ){
        textField1.stringValue = passedString
    }
    
    func updateStatusLabel2(_ passedString: String ){
        textField2.stringValue = passedString
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //if let manufdata = advertisementData["kCBAdvDataManufacturerData"]
        guard let manufdata = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return
        }
        
        packetProcessing1.packetCheck(manufacturerData: manufdata)
    }


    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let hahaha = error {
            print("silly billy \(hahaha)")
        }else{
            print("advertising with no error")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
        //myCentralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.main)
        myPeripheral = CBPeripheralManager(delegate: self, queue: nil)
        
        textField3.stringValue = "fdsafdsafdsafasdfsadfdsafdsafasdffdsafd \n safasdfdsafadsfasfdsafdasdsafdasfdas"
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}


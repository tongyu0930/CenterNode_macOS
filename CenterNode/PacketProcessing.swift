//
//  PacketProcessing.swift
//  CenterNode
//
//  Created by Tong Yu on 2/25/17.
//  Copyright © 2017 Tong Yu. All rights reserved.
//

import Foundation
import CoreBluetooth


class PacketProcessing {
    
    var deviceList = [Int: Int]()
    
    func packetCheck(manufacturerData: Data){
        
            
            let haha3 = Int(String(manufacturerData[5]))
            let haha2 = Int(String(format: "%02X", manufacturerData[0])) // 02: 不管什么数值，都是个2位数
            //let haha2 = String(format: "%X", haha[0])
            print(haha3!, haha2!)
            
            
    }
    
        
    
    
}

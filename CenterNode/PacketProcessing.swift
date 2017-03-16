//
//  PacketProcessing.swift
//  CenterNode
//
//  Created by Tong Yu on 2/25/17.
//  Copyright © 2017 Tong Yu. All rights reserved.
//

import Foundation
import CoreBluetooth


class PacketProcessing
{
    
//    var deviceList  = [Int: Int]()
    var deviceList  = [Int: Array<Int>]()
    
    func packetCheck(manufacturerData: Data) -> String?
    {
        // Data 是 manufacturerData 的数据类型
        
        if (manufacturerData[0] == 84)&&(manufacturerData[1] == 79)&&(manufacturerData[2] == 78)&&(manufacturerData[3] == 71)
        {
            if manufacturerData[4] == 0                                     // alarm node
            {
                return nil
            }
            
            if (manufacturerData[5] == 0)&&(manufacturerData[6] == 0)       // init packet
            {
                return nil
            }
            
            if manufacturerData[10] == 0                                    // self report
            {
//                if let deviceNumber = deviceList[Int(String(manufacturerData[8]))!] {
//                    deviceList[deviceNumber] = Int(String(manufacturerData[9]))
//                    print("old device")
//                } else {
//                    deviceList[Int(String(manufacturerData[8]))!] = Int(String(manufacturerData[9]))
//                    print("new device")
//                }
                
//                if deviceList[Int(String(manufacturerData[8]))!] != nil {
//                    deviceList[Int(String(manufacturerData[8]))!] = [Int(String(manufacturerData[9]))!,0]
//                    print("old device")
//                } else {
//                    deviceList[Int(String(manufacturerData[8]))!] = [Int(String(manufacturerData[9]))!, 0]
//                    print("new device")
//                }
                
                deviceList[Int(String(manufacturerData[8]))!] = [Int(String(manufacturerData[9]))!,0] // 一句话就够了，修改和添加新的项，都是这句话
                // TODO: update table
            }else                                                           // alarm report
            {
                let alarmN = Int(String(manufacturerData[10]))!
                let rssi   = Int(String(manufacturerData[9]))!
                let relayN = Int(String(manufacturerData[8]))!

                
                let alarmReport: String = "Alarm node No.\(alarmN) is close to relay node No.\(relayN) with RSSI: -\(rssi)dB\n"
                return alarmReport
            }
            
            
//            let haha3 = Int(String(manufacturerData[4])) // 好像必须得转两次，不能直接转到int
//            //let haha2 = Int(String(format: "%02X", manufacturerData[0])) // 02: 不管什么数值，都是个2位数
//            print(haha3!, manufacturerData[4])
        }else
        {
            print("noting")
        }
        
        
        
        return nil
    }
    
    
    func counterIncrease()
    {
        for (deviceNumber, deviceInfo) in deviceList
        {
            deviceList[deviceNumber]![1] += 1
            print("\(deviceNumber): \(deviceInfo)")
            
            if deviceList[deviceNumber]![1] >= 10
            {
                deviceList[deviceNumber] = nil
            }
        }
        
        
        // TODO: updata table
        // TODO: notify user something went wrong
        
        
        
    }
    
}

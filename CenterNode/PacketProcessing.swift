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
    
    func packetCheck(manufacturerData: Data){   // Data 是 manufacturerData 的数据类型
        
        if (manufacturerData[0] == 84)&&(manufacturerData[1] == 79)&&(manufacturerData[2] == 78)&&(manufacturerData[3] == 71)
        {
            if manufacturerData[4] == 0
            {
                
            }else
            {
                
            }
            
            let haha3 = Int(String(manufacturerData[4])) // 好像必须得转两次，不能直接转到int
            //let haha2 = Int(String(format: "%02X", manufacturerData[0])) // 02: 不管什么数值，都是个2位数
            print(haha3!, manufacturerData[4])
        }else
        {
            print("fdafdas")
        }
    }
}

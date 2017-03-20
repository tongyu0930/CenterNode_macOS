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
    var deviceList  = [UInt8: Array<UInt8>]()
    
    var Dict:[Character: String]    = [ "A": ":",
                                        "B": ";",
                                        "C": "<",
                                        "D": "=",
                                        "E": ">",
                                        "F": "?",
                                        "1": "1",
                                        "2": "2",
                                        "3": "3",
                                        "4": "4",
                                        "5": "5",
                                        "6": "6",
                                        "7": "7",
                                        "8": "8",
                                        "9": "9",
                                        "0": "0"]
    
    var advList     = Array<String>()
    var alarmList   = Array<String>()
    
    func packetCheck(manufacturerData: Data, rssi: NSNumber) -> String?
    {
        // Data 是 manufacturerData 的数据类型
        
        if (manufacturerData[0] == 84)&&(manufacturerData[1] == 79)&&(manufacturerData[2] == 78)&&(manufacturerData[3] == 71)
        {
            if (manufacturerData[5] == 0)&&(manufacturerData[6] == 0)       // init packet
            {
                return nil
            }
            
            /*********************************** About ACK *****************************/
            
            var advString: String = "TONG01"  // 不用加level了，反正信息不是在厂商data field
            
            if manufacturerData[4] == 0                                         // alarm node
            {
                let adv1: String = transformData(inData: 0) // 00
                let adv2: String = transformData(inData: 0) // 00
                let a = UInt8(String(manufacturerData[7]))
                let adv3: String = transformData(inData: a!) // 编号，十六进制（两位）
                advString.append(adv1)
                advString.append(adv2)
                advString.append(adv3)
                
                if manufacturerData[6] < 10
                {
                    for tempStr in alarmList    // this is to prevent duplicate alarmReport with different RSSI
                    {
                        if tempStr == advString
                        {
                            return nil
                        }
                    }
                    alarmList.append(advString) //"TONG01000002"
                }
                
            }else                                                               // relay node
            {
                if manufacturerData[4] != 2                                     // 只收听level2的信息
                {
                    return nil
                }
                
                let a = UInt8(String(manufacturerData[5]))
                let adv1: String = transformData(inData: a!)
                let b = UInt8(String(manufacturerData[6]))
                let adv2: String = transformData(inData: b!)
                advString.append(adv1)
                advString.append(adv2)
                advString.append("00")
            }
            
            for tempStr in advList
            {
                if tempStr == advString
                {
                    return nil
                }
            }

            advList.append(advString) //"TONG01030500"
            
            
            
            /*********************************** About view *****************************/
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"

            if manufacturerData[4] == 0
            {
                if manufacturerData[6] < 10
                {
                    let alarmN = UInt8(String(manufacturerData[7]))!
                    
                    let alarmReport: String = "Alarm node No.\(alarmN) is close to the Center node with RSSI: \(rssi)dBm at \(formatter.string(from: Date()))"
                    
                    return alarmReport
                }
            }else
            {
                if manufacturerData[10] == 0                                    // self report
                {
                    if manufacturerData[7] != 0                                 // center do not need ACK // 如果是level2发了好几个center没听到，无奈求助于同级，偏偏这个求助packet让center听见了，也没关系，同级会告诉center的，anyway。
                    {
                        return nil
                    }
                    
                    deviceList[UInt8(String(manufacturerData[8]))!] = [UInt8(String(manufacturerData[9]))!,0] // 一句话就够了，修改和添加新的项，都是这句话
                }else                                                           // alarm report
                {
                    let alarmN = UInt8(String(manufacturerData[10]))! // 必须得转换两次，不能直接转到int
                    let rssi   = UInt8(String(manufacturerData[9]))!
                    let relayN = UInt8(String(manufacturerData[8]))!
                    
                    let alarmReportCopy: String = "Alarm node No.\(alarmN) is close to Relay node No.\(relayN) with RSSI: -\(rssi)dBm"

                    for tempStr in alarmList
                    {
                        if tempStr == alarmReportCopy
                        {
                            return nil
                        }
                    }
                    alarmList.append(alarmReportCopy)
                    
                    let alarmReport: String = "Alarm node No.\(alarmN) is close to Relay node No.\(relayN) with RSSI: -\(rssi)dBm at \(formatter.string(from: Date()))"
                    
                    return alarmReport
                }
            }
        }
        return nil
    }
    
    
    func transformData(inData: UInt8) -> String
    {
        let data = [Character](String(format:"%02X", inData).characters)
        
        var outstr: String = Dict[data[0]]!
        outstr += Dict[data[1]]!
        
        return String(describing: outstr)
    }
    
    
    func counterIncrease() -> UInt8?
    {
        var lostNode:UInt8 = 0
        
        for deviceNumber in deviceList.keys
        {
            deviceList[deviceNumber]![1] += 1
            
            if deviceList[deviceNumber]![1] >= 180
            {
                lostNode = deviceNumber
                deviceList[deviceNumber] = nil
                return lostNode
            }
        }
        return nil
    }
}

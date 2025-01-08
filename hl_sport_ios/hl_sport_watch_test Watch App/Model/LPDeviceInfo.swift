//
//  LPDeviceInfo.swift
//  LPHolosport_ios
//
//  Created by gl on 2024/4/24.
//

import CoreBluetooth

struct LPDeviceInfo {

    var name: String?
    var udid: String?
    var mac: String = ""

    var advertisementData: [String: Any]
   
    var peripheral: CBPeripheral?

    var rssi: NSNumber?
}

//
//  BleSettingsTVC.swift
//  SensorTemperature
//
//  Created by Lourenço Gomes on 25/12/2019.
//  Copyright © 2019 Lourenço Gomes. All rights reserved.
//

import Foundation

import UIKit
import CoreBluetooth


// Name=MJ_HT_V1
// Get GATT service, Uuid=0000180f-0000-1000-8000-00805f9b34fb
// Get characteristic for service, Uuid=00002a19-0000-1000-8000-00805f9b34fb
// Read value, Uuid=00002a19-0000-1000-8000-00805f9b34fb
// Value read, Length=1, Data=64
// Get GATT service, Uuid=0000180a-0000-1000-8000-00805f9b34fb
// Get characteristic for service, Uuid=00002a26-0000-1000-8000-00805f9b34fb
// Read value, Uuid=00002a26-0000-1000-8000-00805f9b34fb
// Value read, Length=8, Data=30-30-2E-30-30-2E-36-36

// Name=MJ_HT_V1
// Get GATT service, Uuid=226c0000-6476-4566-7562-66734470666d
// Get characteristic for service, Uuid=226caa55-6476-4566-7562-66734470666d
// Register characteristic notification handler, Uuid=226caa55-6476-4566-7562-66734470666d
//
// Temperature 24.3 °C
// Air humidity 44.6 %

let kDeviceInformation        = "180A"
let kBatteryService           = "180F"
let kControlService           = "226C0000-6476-4566-7562-66734470666D"

let kDataCharacteristic       = "226CAA55-6476-4566-7562-66734470666D"


let kCharHWVer                = "2A27"
let kCharFWVer                = "2A26"
let kCharBatteryLevel         = "2A19"
let kCharManufactor           = "2A29"
let kCharModel                = "2A24"
let kCharSerial               = "2A25"

let kStartOperation       :[UInt8] = [ 0x01, 0x00 ]//"01"
let kStopOperation        :[UInt8] = [ 0x00, 0x00 ]//"00"


struct BleDevice {
    var peripheral : CBPeripheral?
    var rssi : NSNumber?
    var identifier : String?
    var name: String?
    var fwVer : String?
    var hwVer : String?
    var batteryLevel : Int?
    var value : Int?
    var selected : Bool?
    var type : String?
}


class BleSettingsTVC: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
 
     let defaults :UserDefaults = UserDefaults.standard
    
    var hrUUID : CBUUID?
    var hrCharacteristic: CBCharacteristic?
    var hrSrevice : CBService?
    var centralManager : CBCentralManager?
    
    var hrCBUUIDs  : [CBUUID]  = []

    var timer : Timer?
    
    var bleDevices = [BleDevice]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateRSSI), userInfo: nil, repeats: true)
        

        // Do any additional setup after loading the view.
    }

    
    @objc func updateRSSI(){
        for bleDevice in bleDevices {
            bleDevice.peripheral?.readRSSI()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        for index in 0..<bleDevices.count {
            if bleDevices[index].identifier! == peripheral.identifier.uuidString {
                bleDevices[index].rssi = RSSI
            }
        }
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        centralManager=CBCentralManager.init(delegate: self, queue: nil)

        hrCBUUIDs = [
            CBUUID.init(string: kControlService    ),
            CBUUID.init(string: kDataCharacteristic),
            CBUUID.init(string: kDeviceInformation ),
            CBUUID.init(string: kBatteryService    )]
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        for bleDevice in bleDevices {
            disconnectBleDevice(bleDevice: bleDevice)
        }
    }
    
    func disconnectBleDevice(bleDevice:BleDevice) {
        self.centralManager?.cancelPeripheralConnection(bleDevice.peripheral!)
        bleDevice.peripheral!.delegate=nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {

        centralManager?.stopScan()
        centralManager?.delegate=nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bleDevices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTVC", for: indexPath) as! TempTVCell

        // Configure the cell...

        cell.labelDescriptiopn.text = "\(bleDevices[indexPath.row].name!), ST:\(bleDevices[indexPath.row].rssi ?? 0) FW:\(bleDevices[indexPath.row].fwVer!) HW:\(bleDevices[indexPath.row].hwVer!) BAT:\(bleDevices[indexPath.row].batteryLevel!)"
        cell.labelTitle.text = "\(bleDevices[indexPath.row].type!)"
        cell.accessoryType = bleDevices[indexPath.row].selected! ? .checkmark : .none
        

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bleDevices[indexPath.row].selected = !bleDevices[indexPath.row].selected!
        tableView.reloadData()
    }

    // MARK: - BLE
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        self.centralManager = central
        if central.state != .poweredOn {
            if central.state == .unsupported{
                let alert = UIAlertController.init(title: NSLocalizedString("Bluetooth not available!", comment: ""), message: NSLocalizedString("This device does not support BLE.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("Dismiss", comment: ""),
                                                   style: .default,
                                                   handler: { action in }));
                self.present(alert, animated: true, completion: nil)
            }else if central.state == .poweredOff{
                let alert = UIAlertController.init(title: NSLocalizedString(NSLocalizedString("Bluetooth not active!", comment: ""), comment: ""), message: "Please turn on bluetooth.", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: NSLocalizedString("Dismiss", comment: ""),
                                                   style: .default,
                                                   handler: { action in }));
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            central.scanForPeripherals(withServices: nil, options: nil)
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if let adv = advertisementData["kCBAdvDataLocalName"] as? String{
            if adv == "MJ_HT_V1" {
                
                for bleDevice in bleDevices {
                    if peripheral.identifier.uuidString == bleDevice.identifier {
                        return
                    }
                }
                
                bleDevices.append(BleDevice(peripheral: peripheral,
                                                  rssi: RSSI,
                                            identifier: peripheral.identifier.uuidString,
                                                  name: peripheral.name!,
                                                 fwVer: "",
                                                 hwVer: "",
                                          batteryLevel: 0,
                                                 value: 0,
                                              selected: false,
                                                  type: "HR"))
                self.centralManager?.connect(peripheral, options:nil)
                peripheral.delegate=self
            }
            
        }
        tableView.reloadData()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
       // print("didDiscoverServices")
        if let services = peripheral.services{
            for  s  in services {
               peripheral.discoverCharacteristics(nil, for: s)
                //print("didDiscoverServices:\(s.uuid)")
            }
        }
        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //print("didDisconnectPeripheral:\(peripheral.name)")
        self.centralManager?.connect(peripheral, options:nil)
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //print("didDiscoverCharacteristicsFor")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("didDiscoverCharacteristicsFor:\(characteristic.uuid.uuidString)")
                if  characteristic.uuid.uuidString == kCharFWVer                ||
                    characteristic.uuid.uuidString == kCharHWVer                ||
                    characteristic.uuid.uuidString == kCharBatteryLevel         ||
                    characteristic.uuid.uuidString == kDataCharacteristic
                   
                {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
              
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //print("didUpdateNotificationStateFor")
        //print("UpdateNotificationStateFor:\(peripheral.name ?? "no" ): char:\(characteristic.uuid) ")
    }
    

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let errorAnswe = error {
            //print (errorAnswe)
        }
        guard let data = characteristic.value  else {
            print("no data")
            return
        }
        let uuidc  = characteristic.uuid.uuidString
        let uuids  = peripheral.identifier.uuidString
        
        print("characteristic:\(uuidc) Data:\(String(decoding: data, as: UTF8.self))")
        
        for index in 0..<bleDevices.count {
            if bleDevices[index].identifier == uuids {

                if uuidc == kCharBatteryLevel
                {
                    let byteArray = [UInt8](data)
                    bleDevices[index].batteryLevel=Int(byteArray[0])
                    print("Batery:\(uuidc) Data:\(String(decoding: data, as: UTF8.self))")
                }
                if uuidc == kCharFWVer
                {
                    bleDevices[index].hwVer=String(data: data, encoding: .utf8)
                    print("FW:\(uuidc) Data:\(String(decoding: data, as: UTF8.self))")
                }
                if uuidc == kCharHWVer
                {
                    bleDevices[index].fwVer=String(data: data, encoding: .utf8)
                    print("HW:\(uuidc) Data:\(String(decoding: data, as: UTF8.self))")
                }
                
                if uuidc == kDataCharacteristic
                {
                    bleDevices[index].type=String(decoding: data, as: UTF8.self)
                    print("DATA:\(uuidc) Data:\(String(decoding: data, as: UTF8.self))")
                }
                
                
                
            }
            
            
        }
        tableView.reloadData()
    }
    
    

}

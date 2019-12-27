//
//  BLEUtility.h
//  SensorTemperature
//
//  Created by Lourenço Gomes on 25/12/2019.
//  Copyright © 2019 Lourenço Gomes. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define LUMINUS_LONG_UUID @"85250FF0-5EC0-B52C-ACE7-65B5C1A07F67"

@interface BLEUtility : NSObject

+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID;

+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;
+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

+(void)writeCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data;
+(void)readCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID;
+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID enable:(BOOL)enable;

+(bool) isCharacteristicNotifiable:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *) cCBUUID;

/// Function to expand a TI 16-bit UUID to TI 128-bit UUID
+(CBUUID *) expandToTIUUID:(CBUUID *)sourceUUID;
/// Function to convert an CBUUID to NSString
+(NSString *) CBUUIDToString:(CBUUID *)inUUID;

@end


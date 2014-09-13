//
//  TLHMViewController.h
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MBConnectionViewController : UIViewController<CBCentralManagerDelegate>

- (void)foundBoard:(CBPeripheral*)board;


@end

//
//  TLHMViewController.h
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface MBConnectionViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate>

- (void)foundBoard:(CBPeripheral*)board;
@property (weak, nonatomic) IBOutlet UILabel *myoLabel;
@property (weak, nonatomic) IBOutlet UILabel *boostedLabel;

@end

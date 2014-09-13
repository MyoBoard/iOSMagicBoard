//
//  BTPickerController.h
//  HelloMyo
//
//  Created by Gregory Carlin on 9/13/14.
//  Copyright (c) 2014 Thalmic Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBConnectionViewController.h"

@interface BTPickerController : UITableViewController

- (id)initWithParent:(MBConnectionViewController*) parent andBTManager:(CBCentralManager*) manager;
- (void)addPeripheral:(CBPeripheral*) peripheral;

@end

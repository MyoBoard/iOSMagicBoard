//
//  BTPickerController.h
//  HelloMyo
//
//  Created by Gregory Carlin on 9/13/14.
//  Copyright (c) 2014 Thalmic Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TLHMViewController.h"

@interface BTPickerController : UITableViewController<CBCentralManagerDelegate>

- (id)initWithParent:(TLHMViewController*) parent;

@end

//
//  BTPickerController.m
//  HelloMyo
//
//  Created by Gregory Carlin on 9/13/14.
//  Copyright (c) 2014 Thalmic Labs. All rights reserved.
//

#import "BTPickerController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TLHMViewController.h"

@interface BTPickerController ()

@property CBCentralManager *btManager;
@property NSMutableArray *peripherals;
@property TLHMViewController *parent;

@end

@implementation BTPickerController

- (id)initWithParent:(TLHMViewController*) parent andBTManager:(CBCentralManager *)manager {
    self = [super init];
    
    self.parent = parent;
    self.btManager = manager;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.peripherals = [NSMutableArray array];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.btManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.btManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell) return cell;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    CBPeripheral* per = [self.peripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = per.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.btManager stopScan];
    [self.parent foundBoard:[self.peripherals objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:

*/

- (void)addPeripheral:(CBPeripheral*)peripheral {
    [self.peripherals addObject:peripheral];
    [self.tableView reloadData];
}

@end

//
//  MBMainViewController.m
//  HelloMyo
//
//  Created by Niko Lazaris on 9/13/14.
//  Copyright (c) 2014 Thalmic Labs. All rights reserved.
//

#import "MBMainViewController.h"
#import <MyoKit/MyoKit.h>
#import "MBConnectionViewController.h"
#import "GRKCircularGraphView.h"
#import "MBUserInterface.h"

@interface MBMainViewController ()

@end

@implementation MBMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain target:self action:@selector(startConnect:)];
    connectButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = connectButton;

    self.accelLabel.textColor = kMyoBlue;
    self.myoLabel.textColor = kLightGrey;
    self.boardLabel.textColor = kLightGrey;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startConnect:(id)sender {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    UIViewController *controller = [[MBConnectionViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    // Present the settings view controller modally.
    navigationController.navigationBar.barTintColor = kMyoBlue;
    navigationController.navigationBar.tintColor   = [UIColor whiteColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.shadowImage = nil;
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end

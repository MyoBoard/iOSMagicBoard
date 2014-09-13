//
//  MBViewController.m
//  MagicBoard
//
//  Created by Gregory Carlin on 9/12/14.
//  Copyright (c) 2014 MyoBoard. All rights reserved.
//

#import "MBViewController.h"
#import <MyoKit/MyoKit.h>

@interface MBViewController ()

@end

@implementation MBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"presenting settings");
    [self pushMyoSettings];
    //[self.lbl setText:@"hi"];
    //[self modalPresentMyoSettings];
    //[self attachToAnyMyo];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];*/
}

/*- (void)didReceivePoseChange:(NSNotification*)notification {
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    
    NSLog(@"got pose change");
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Pushing it on an existing navigation controller
- (void)pushMyoSettings {
    TLMSettingsViewController *settings = [[TLMSettingsViewController alloc] init];
    
    [self pushViewController:settings animated:YES];
}

// Presenting modally
- (void)modalPresentMyoSettings {
    UINavigationController *settings = [TLMSettingsViewController settingsInNavigationController];
    
    [self presentViewController:settings animated:YES completion:nil];
}

// Connecting to a Myo with attachToAny
- (void)attachToAnyMyo {
    [[TLMHub sharedHub] attachToAny];
}

// Connecting to a Myo with attachToAdjacent
- (void)attachToAdjacentMyo {
    [[TLMHub sharedHub] attachToAdjacent];
}

// Connecting to a Myo by its identifier
// The identifier for a Myo can be retrieved from the TLMMyo's identifier property
- (void)attachToMyoByIdentifier:(NSUUID *)identifier {
    [[TLMHub sharedHub] attachByIdentifier:identifier];
}

@end

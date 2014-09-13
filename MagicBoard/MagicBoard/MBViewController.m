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
    //[self pushMyoSettings];
}

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
    
    [self.navigationController pushViewController:settings animated:YES];
}

@end

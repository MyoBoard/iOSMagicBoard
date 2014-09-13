//
//  MBDetailViewController.h
//  MagicBoard
//
//  Created by Niko Lazaris on 9/12/14.
//  Copyright (c) 2014 MyoBoard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

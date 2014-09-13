//
//  TLHMViewController.m
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import "TLHMViewController.h"
#import <MyoKit/MyoKit.h>

@interface TLHMViewController ()

@property (weak, nonatomic) IBOutlet UILabel *accelLabel;
@property (nonatomic) float trueAccel;
@property (nonatomic) float effectiveAccel;
@property (strong, nonatomic) TLMPose *currentPose;

- (IBAction)didTapSettings:(id)sender;

@end

@implementation TLHMViewController

#pragma mark - View Lifecycle

- (id)init {
    // Initialize our view controller with a nib (see TLHMViewController.xib).
    self = [super initWithNibName:@"TLHMViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a Sync Gesture, and the Myo is calibrated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeArm:)
                                                 name:TLMMyoDidReceiveArmRecognizedEventNotification
                                               object:nil];
    // Posted whenever Myo loses its calibration (when Myo is taken off, or moved enough on the user's arm)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoseArm:)
                                                 name:TLMMyoDidReceiveArmLostEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter Methods

- (void)didConnectDevice:(NSNotification *)notification {
    // Align our label to be in the center of the view.
    //[self.helloLabel setCenter:self.view.center];
    //[self.accelLabel setBounds:CGRectMake(10, 10, 100, 50)];
    [self.accelLabel setCenter:self.view.center];
    self.accelLabel.text = @"Unknown";

    // Set the text of the armLabel to "Perform the Sync Gesture"
    /*self.armLabel.text = @"Perform the Sync Gesture";

    // Set the text of our helloLabel to be "Hello Myo".
    self.helloLabel.text = @"Hello Myo";

    // Show the acceleration progress bar
    [self.accelerationProgressBar setHidden:NO];
    [self.accelerationLabel setHidden:NO];*/
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    // Remove the text of our label when the Myo has disconnected.
    /*self.helloLabel.text = @"";
    self.armLabel.text = @"";

    // Hide the acceleration progress bar
    [self.accelerationProgressBar setHidden:YES];
    [self.accelerationLabel setHidden:YES];*/
    
    self.accelLabel.text = @"Unknown";
}

- (void)didRecognizeArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmRecognizedEvent key.
    /*TLMArmRecognizedEvent *armEvent = notification.userInfo[kTLMKeyArmRecognizedEvent];

    // Update the armLabel with arm information
    NSString *armString = armEvent.arm == TLMArmRight ? @"Right" : @"Left";
    NSString *directionString = armEvent.xDirection == TLMArmXDirectionTowardWrist ? @"Toward Wrist" : @"Toward Elbow";
    self.armLabel.text = [NSString stringWithFormat:@"Arm: %@ X-Direction: %@", armString, directionString];*/
}

- (void)didLoseArm:(NSNotification *)notification {
    // Reset the armLabel and helloLabel
    /*self.armLabel.text = @"Perform the Sync Gesture";
    self.helloLabel.text = @"Hello Myo";
    self.helloLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
    self.helloLabel.textColor = [UIColor blackColor];*/
    self.accelLabel.text = @"Unknown";
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];

    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    /*NSLog(@"pitch: %@", angles.pitch);
    NSLog(@"yaw: %@", angles.yaw);
    NSLog(@"roll: %@", angles.roll);*/
    //NSLog(@"(%f, %f, %f)", angles.pitch.degrees, angles.yaw.degrees, angles.roll.degrees);
    [self setAcceleration:angles.roll.degrees];

    /*// Next, we want to apply a rotation and perspective transformation based on the pitch, yaw, and roll.
    CATransform3D rotationAndPerspectiveTransform = CATransform3DConcat(CATransform3DConcat(CATransform3DRotate (CATransform3DIdentity, angles.pitch.radians, -1.0, 0.0, 0.0), CATransform3DRotate(CATransform3DIdentity, angles.yaw.radians, 0.0, 1.0, 0.0)), CATransform3DRotate(CATransform3DIdentity, angles.roll.radians, 0.0, 0.0, -1.0));

    // Apply the rotation and perspective transform to helloLabel.
    self.helloLabel.layer.transform = rotationAndPerspectiveTransform;*/
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
    /*TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];

    // Get the acceleration vector from the accelerometer event.
    GLKVector3 accelerationVector = accelerometerEvent.vector;

    // Calculate the magnitude of the acceleration vector.
    float magnitude = GLKVector3Length(accelerationVector);

    // Update the progress bar based on the magnitude of the acceleration vector.
    self.accelerationProgressBar.progress = magnitude / 8;*/

    /* Note you can also access the x, y, z values of the acceleration (in G's) like below
     float x = accelerationVector.x;
     float y = accelerationVector.y;
     float z = accelerationVector.z;
     */
}

- (void)setAcceleration:(float)accel {
    self.trueAccel = accel;
    if(self.currentPose.type == TLMPoseTypeFist) {
        self.effectiveAccel = accel;
        self.accelLabel.text = [NSString stringWithFormat:@"%f", accel];
    } else {
        self.effectiveAccel = 0.0;
        self.accelLabel.text = @"0.0";
    }
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    /*TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    float roll = angles.roll.degrees;*/

    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeWaveIn:
        case TLMPoseTypeWaveOut:
        case TLMPoseTypeFingersSpread:
        case TLMPoseTypeThumbToPinky:
            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
            /*self.helloLabel.text = @"Hello Myo";
            self.helloLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
            self.helloLabel.textColor = [UIColor blackColor];*/
            NSLog(@"neutral pose");
            self.effectiveAccel = 0.0;
            self.accelLabel.text = @"0.0";
            break;
        case TLMPoseTypeFist:
            NSLog(@"fist pose");
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            /*self.helloLabel.text = @"Fist";
            self.helloLabel.font = [UIFont fontWithName:@"Noteworthy" size:50];
            self.helloLabel.textColor = [UIColor greenColor];*/
            self.effectiveAccel = self.trueAccel;
            self.accelLabel.text = [NSString stringWithFormat:@"%f", self.trueAccel];
            break;
        /*case TLMPoseTypeWaveIn:
            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
            self.helloLabel.text = @"Wave In";
            self.helloLabel.font = [UIFont fontWithName:@"Courier New" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeWaveOut:
            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
            self.helloLabel.text = @"Wave Out";
            self.helloLabel.font = [UIFont fontWithName:@"Snell Roundhand" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeFingersSpread:
            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
            self.helloLabel.text = @"Fingers Spread";
            self.helloLabel.font = [UIFont fontWithName:@"Chalkduster" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeThumbToPinky:
            // Changes helloLabel's font to Superclarendon when the user is in a twist in pose.
            self.helloLabel.text = @"Thumb to Pinky";
            self.helloLabel.font = [UIFont fontWithName:@"Georgia" size:50];
            self.helloLabel.textColor = [UIColor greenColor];
            break;*/
    }
}

- (IBAction)didTapSettings:(id)sender {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
}

@end

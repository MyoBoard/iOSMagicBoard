//
//  TLHMViewController.m
//  HelloMyo
//
//  Copyright (c) 2013 Thalmic Labs. All rights reserved.
//  Distributed under the Myo SDK license agreement. See LICENSE.txt.
//

#import "MBConnectionViewController.h"
#import <MyoKit/MyoKit.h>
#import "BTPickerController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBUserInterface.h"

@interface MBConnectionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *accelLabel;
@property (weak, nonatomic) IBOutlet UIButton *myoButton;
@property (weak, nonatomic) IBOutlet UIButton *boostedButton;
@property (nonatomic) float trueAccel;
@property (nonatomic) float effectiveAccel;
@property TLMPose *currentPose;
@property CBCentralManager *btManager;
@property BTPickerController *btPicker;

- (IBAction)didTapSettings:(id)sender;

@end

@implementation MBConnectionViewController

#pragma mark - View Lifecycle

- (id)init {
    // Initialize our view controller with a nib (see TLHMViewController.xib).
    self = [super initWithNibName:@"MBConnectionViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accelLabel.textColor    = kMyoBlue;
    self.myoButton.tintColor     = kMyoBlue;
    self.boostedButton.tintColor = kMyoBlue;
    self.myoLabel.textColor      = kLightGrey;
    self.boostedLabel.textColor  = kLightGrey;
    
//    self.navigationItem.titleView = [UITextView alloc]in
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
    self.accelLabel.text = @"Unknown";
    
    [self.boostedButton setEnabled:YES];

    // Set the text of the armLabel to "Perform the Sync Gesture"
    /*self.armLabel.text = @"Perform the Sync Gesture";

    // Set the text of our helloLabel to be "Hello Myo".
    self.helloLabel.text = @"Hello Myo";*/
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    self.accelLabel.text = @"";
    [self.boostedButton setEnabled:NO];
    [self.boostedButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateDisabled];
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
        // TODO send to bluetooth
        self.effectiveAccel = accel;
        self.accelLabel.text = [NSString stringWithFormat:@"%f", accel];
    } else {
        self.effectiveAccel = 0.0;
        self.accelLabel.text = @"0.0";
    }
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    //NSLog(@"pose change");
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;

    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeWaveIn:
        case TLMPoseTypeWaveOut:
        case TLMPoseTypeFingersSpread:
        case TLMPoseTypeThumbToPinky:
            //NSLog(@"neutral pose");
            self.effectiveAccel = 0.0;
            self.accelLabel.text = @"0.0";
            break;
        case TLMPoseTypeFist:
            //NSLog(@"fist pose");
            self.effectiveAccel = self.trueAccel;
            self.accelLabel.text = [NSString stringWithFormat:@"%f", self.trueAccel];
            break;
    }
}

-(void)cancelConnect
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)didTapSettings:(id)sender {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    TLMSettingsViewController *controller = [[TLMSettingsViewController alloc]init];
    // Present the settings view controller modally.
//    controller.navigationBar.translucent = NO;
//    controller.navigationBar.barTintColor = kMyoBlue;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)didTapBoard:(id)sender {
    self.btManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.btPicker = [[BTPickerController alloc] initWithParent:self andBTManager:self.btManager];
    [self.navigationController pushViewController:self.btPicker animated:YES];
}

- (void)foundBoard:(CBPeripheral*)board {
    NSLog(@"tapped %@", board.name);
    [self.btManager connectPeripheral:board options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"peripheral connected");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    //NSLog(@"Discovered %@", peripheral.name);
    [self.btPicker addPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
}

- (void)peripheral:(CBPeripheral *)peripheral
    didDiscoverServices:(NSError *)error {
    // identifier = AE7750C2-A13A-4AB8-AD7F-6BCFC11FBD98
    // UUID = 08C8C7A0-6CC5-11E3-981F-0800200C9A66
    
    // identifier = AE7750C2-A13A-4AB8-AD7F-6BCFC11FBD98
    // D752C5FB-1380-4CD5-B0EF-CAC7D72CFF20
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service.UUID.UUIDString);
        if([service.UUID.UUIDString isEqualToString:@"08C8C7A0-6CC5-11E3-981F-0800200C9A66"]) {
        //if([service.UUID.UUIDString isEqualToString:@"D752C5FB-1380-4CD5-B0EF-CAC7D72CFF20"]) {
        //if([service.UUID.UUIDString isEqualToString:@"DA2B84F1-6279-48DE-BDC0-AFBEA0226079"]) {
            NSLog(@"match");
            [peripheral discoverCharacteristics:nil forService:service];
            //break;
        } else {
            NSLog(@"no match");
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    NSLog(@"service %@", service.UUID.UUIDString);
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"UUID = %@, VALUE = %@", characteristic.UUID.UUIDString, characteristic.value);
        //NSLog(@"Discovered characteristic %@", characteristic);
    }
}


@end

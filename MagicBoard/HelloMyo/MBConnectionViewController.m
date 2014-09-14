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
#import "GRKCircularGraphView.h"

@interface MBConnectionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *myoButton;
@property (weak, nonatomic) IBOutlet UIButton *boostedButton;
@property (nonatomic) float trueAccel;
@property (nonatomic) float effectiveAccel;
@property (nonatomic) float originalRoll;
@property (nonatomic) BOOL originalRollSet;
@property (nonatomic) float lastSent;
@property (nonatomic) double lastSentTime;
//@property TLMPose *currentPose;
@property (nonatomic) float currentPitch;
@property CBCentralManager *btManager;
@property BTPickerController *btPicker;
@property CBPeripheral *periph;
@property CBCharacteristic *characteristic;
//@property (nonatomic) BOOL towardWrist;
@property (nonatomic) BOOL alertedToMax;

- (IBAction)didTapSettings:(id)sender;

@end

@implementation MBConnectionViewController

#pragma mark - View Lifecycle

- (id)init {
    // Initialize our view controller with a nib (see TLHMViewController.xib).
    self = [super initWithNibName:@"MBConnectionViewController" bundle:nil];
    self.originalRollSet = NO;
    //self.towardWrist = YES;
    self.alertedToMax = NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.accelLabel.textColor    = kMyoBlue;
    self.myoButton.tintColor     = kMyoBlue;
    self.boostedButton.tintColor = kMyoBlue;
    self.myoLabel.textColor      = kLightGrey;
    self.boostedLabel.textColor  = kLightGrey;
    
    self.graphView.clockwise = YES;
    self.graphView.startAngle = 1.6f;
    self.graphView.backgroundColor = [UIColor clearColor];
    self.graphView.tintColor = kMyoBlue;
    
    [self updateViewConstraints];
    
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"navicon"]];
//    self.navigationItem.title = @"Magic";
    
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
    self.myoLabel.text = @"Myo Connected!";
    self.myoLabel.textColor = [UIColor grayColor];

    // Set the text of the armLabel to "Perform the Sync Gesture"
    /*self.armLabel.text = @"Perform the Sync Gesture";

    // Set the text of our helloLabel to be "Hello Myo".
    self.helloLabel.text = @"Hello Myo";*/
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    self.accelLabel.text = @"";
    self.myoLabel.text = @"Myo Device Not Connected...";
    self.myoLabel.textColor = kLightGrey;
    [self.boostedButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateDisabled];
}

- (void)didRecognizeArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmRecognizedEvent key.
    /*TLMArmRecognizedEvent *armEvent = notification.userInfo[kTLMKeyArmRecognizedEvent];

    // Update the armLabel with arm information
    NSString *armString = armEvent.arm == TLMArmRight ? @"Right" : @"Left";
    NSLog(@"arm = %@", armString);*/
    // toward wrist = light up
    //self.towardWrist = armEvent.xDirection == TLMArmXDirectionTowardWrist;
    //NSString *directionString = armEvent.xDirection == TLMArmXDirectionTowardWrist ? @"Toward Wrist" : @"Toward Elbow";
    //NSLog(@"dir = %@", directionString);
}

- (void)didLoseArm:(NSNotification *)notification {
    self.accelLabel.text = @"Unknown";
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];

    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    self.currentPitch = angles.pitch.degrees;
    /*if(self.towardWrist) {
        NSLog(@"flipping pitch");
        self.currentPitch *= -1;
    }*/
    if(self.currentPitch > 10) {
        //NSLog(@"disabling originalRoll");
        self.originalRollSet = NO;
    } else if(self.currentPitch < 10 && !self.originalRollSet) {
        self.originalRollSet = YES;
        self.originalRoll = angles.roll.degrees;
        [[[[TLMHub sharedHub] myoDevices] objectAtIndex:0] vibrateWithLength:TLMVibrationLengthMedium];
        //NSLog(@"setting originalRoll to %f", self.originalRoll);
    }
    
    //NSLog(@"(%f, %f, %f)", angles.pitch.degrees, angles.yaw.degrees, angles.roll.degrees);
    [self setAcceleration:angles.roll.degrees];
    
    /*if(!self.originalRollSet) {
        self.originalRollSet = YES;
        self.originalRoll = angles.roll.degrees;
    }*/
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
    //if(self.currentPose.type == TLMPoseTypeFist) {
    if(self.currentPitch < 10) {
        self.effectiveAccel = accel;
        double currentTime = CACurrentMediaTime();
        //NSLog(@"currentTime = %f; lastSentTime = %f", currentTime, self.lastSentTime);
        float newVal = self.effectiveAccel - self.originalRoll;
        newVal = MAX(newVal, -45.0f);
        newVal = MIN(newVal, 45.0f);
        if(ABS(newVal) >= 45.0f) {
            if(!self.alertedToMax) {
                [[[[TLMHub sharedHub] myoDevices] objectAtIndex:0] vibrateWithLength:TLMVibrationLengthShort];
                self.alertedToMax = YES;
            }
        } else {
            self.alertedToMax = NO;
        }
        if(self.characteristic && currentTime - self.lastSentTime > 0.200 && newVal != self.lastSent) {
            self.lastSentTime = currentTime;
            self.lastSent = newVal;
            NSString* str = [NSString stringWithFormat:@"%f", newVal];
            NSLog(@"1 - %@", str);
            NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"data = %@", data);
            [self.periph writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        }
        NSNumberFormatter* fmt = [[NSNumberFormatter alloc] init];
        [fmt setPositiveFormat:@"0.#"];
        self.accelLabel.text = [fmt stringFromNumber:[NSNumber numberWithFloat:newVal]];
        if (newVal >= 0){
            self.graphView.clockwise = YES;
            self.graphView.percent = newVal/45;
            self.graphView.backgroundColor = [UIColor clearColor];
            self.accelLabel.textColor = kMyoBlue;
            self.graphView.tintColor = kMyoBlue;
        } else {
            self.graphView.clockwise = NO;
            self.graphView.percent = newVal/-45;
            self.graphView.backgroundColor = [UIColor clearColor];
            self.graphView.tintColor = kReverseRed;
            self.accelLabel.textColor = kReverseRed;
        }

    } else {
        self.effectiveAccel = 0.0;
        //double currentTime = CACurrentMediaTime();
        if(self.characteristic && /*currentTime - self.lastSentTime > 0.®200 &&*/ self.effectiveAccel != self.lastSent) {
            //self.lastSentTime = currentTime;
            self.lastSent = self.effectiveAccel;
            NSString* str = [NSString stringWithFormat:@"%f", self.effectiveAccel];
            NSLog(@"2 - %@ ", str);
            NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"data = %@", data);
            [self.periph writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        }
        self.accelLabel.text = @"0.0";
        self.graphView.percent = 0.0f;
    }
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    //NSLog(@"pose change");
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    /*TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;

    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeWaveIn:
        case TLMPoseTypeWaveOut:
        case TLMPoseTypeFingersSpread:
        case TLMPoseTypeThumbToPinky:
            NSLog(@"neutral pose");
            self.effectiveAccel = 0.0;
            self.accelLabel.text = @"0.0";
            break;
        case TLMPoseTypeFist:
            NSLog(@"fist pose");
            self.effectiveAccel = self.trueAccel;
            self.accelLabel.text = [NSString stringWithFormat:@"%f", self.trueAccel];
            break;
    }*/
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
    self.boostedLabel.text = @"Boosted Connect!";
    self.boostedLabel.textColor = [UIColor grayColor];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

// TODO doesn't work
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"peripheral disconnected");
    self.boostedLabel.text = @"Boosted Not Connected...";
    self.boostedLabel.textColor = kLightGrey;
    self.periph = nil;
    self.characteristic = nil;
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
    //NSLog(@"updateState: %d", central.state);
    if(central.state == CBCentralManagerStateUnknown){
        [central cancelPeripheralConnection:self.periph];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
}

- (void)peripheral:(CBPeripheral *)peripheral
    didDiscoverServices:(NSError *)error {
    // UUID = 08C8C7A0-6CC5-11E3-981F-0800200C9A66
    // UUID = D752C5FB-1380-4CD5-B0EF-CAC7D72CFF20
    
    for (CBService *service in peripheral.services) {
        if([service.UUID.UUIDString isEqualToString:@"D752C5FB-1380-4CD5-B0EF-CAC7D72CFF20"]) {
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    // store first characteristic encountered
    if(!self.characteristic) {
        self.periph = peripheral;
        self.characteristic = [service.characteristics objectAtIndex:0];
    }
}

@end

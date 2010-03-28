//
//  MainViewController.h
//  DelSol
//
//  Created by P. Mark Anderson on 2/20/10.
//  Copyright Spot Metrix, Inc. 2010. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "FlipsideViewController.h"
#import "SM3DAR.h"
#import "Dpad.h"
#import "Joystick.h"


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, SM3DAR_Delegate, CLLocationManagerDelegate> {
    SM3DAR_Point *point;
    SM3DAR_Point *sun;
    BOOL moveMode;
    Joystick *joystick;
}

@property (nonatomic, retain) SM3DAR_Point *point;
@property (nonatomic, retain) SM3DAR_Point *sun;
@property (nonatomic, retain) Joystick *joystick;

- (IBAction)showInfo;
- (IBAction)toggleMode:(UIButton*)button;

@end

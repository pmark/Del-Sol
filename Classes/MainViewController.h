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

typedef enum {
  MoveDirectionNeither,
  MoveDirectionPositive,
  MoveDirectionNegative
} MoveDirection;


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, SM3DAR_Delegate, CLLocationManagerDelegate> {
  SM3DAR_Point *point;
  BOOL moveMode;
  MoveDirection moveDirection;
  NSInteger moveAxis;
  IBOutlet UISegmentedControl *positiveBar;
  IBOutlet UISegmentedControl *negativeBar;
  Joystick *dpad;
}

@property (nonatomic, retain) SM3DAR_Point *point;
@property (nonatomic, retain) IBOutlet UISegmentedControl *positiveBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *negativeBar;
@property (nonatomic, retain) Joystick *dpad;

- (IBAction)showInfo;
- (IBAction)toggleMode:(UIButton*)button;
- (void)moveOnAxis:(NSInteger)axis direction:(MoveDirection)direction;

@end

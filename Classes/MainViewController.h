//
//  MainViewController.h
//  PointAndTilt
//
//  Created by P. Mark Anderson on 2/20/10.
//  Copyright Bordertown Labs, LLC 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SM3DAR.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, SM3DAR_Delegate> {
}

- (IBAction)showInfo;

@end

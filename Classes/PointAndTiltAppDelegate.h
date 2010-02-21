//
//  PointAndTiltAppDelegate.h
//  PointAndTilt
//
//  Created by P. Mark Anderson on 2/20/10.
//  Copyright Bordertown Labs, LLC 2010. All rights reserved.
//

@class MainViewController;

@interface PointAndTiltAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

@end


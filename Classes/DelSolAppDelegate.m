//
//  DelSolAppDelegate.m
//  DelSol
//
//  Created by P. Mark Anderson on 2/20/10.
//  Copyright Spot Metrix, Inc. 2010. All rights reserved.
//

#import "DelSolAppDelegate.h"
#import "MainViewController.h"

@implementation DelSolAppDelegate


@synthesize window;
@synthesize mainViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
  
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
  mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
  [window makeKeyAndVisible];
}


- (void)dealloc {
  [mainViewController release];
  [window release];
  [super dealloc];
}

@end

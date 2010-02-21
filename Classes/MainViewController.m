//
//  MainViewController.m
//  PointAndTilt
//
//  Created by P. Mark Anderson on 2/20/10.
//  Copyright Bordertown Labs, LLC 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "SphereView.h"

@implementation MainViewController

@synthesize point;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    // Custom initialization
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];

  SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedSM3DAR_Controller];
  sm3dar.delegate = self;
  [self.view addSubview:sm3dar.view];  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];  
  
}

- (void)loadPointsOfInterest {

  // create point
  self.point = [[SM3DAR_Fixture alloc] init];
  
  // give point a view
  NSString *texture = nil; //@"sphere_texture1.png";
  SphereView *sphereView = [[SphereView alloc] initWithTextureNamed:texture];
  point.view = sphereView;  

  // add point
  SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedSM3DAR_Controller]; 
  [sm3dar addPointOfInterest:point];
  
  [NSTimer scheduledTimerWithTimeInterval:0.10f target:self selector:@selector(tick) userInfo:nil repeats:YES];  
}

- (void)tick {
  [point translateX:1.0f y:0 z:0];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
  
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [point release];
  [super dealloc];
}


@end

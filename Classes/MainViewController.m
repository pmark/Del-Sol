//
//  MainViewController.m
//  DelSol
//
//  Created by P. Mark Anderson on 2/20/10.
//  Copyright Spot Metrix, Inc. 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "SphereView.h"
#import "RoundedLabelMarkerView.h"

#define BTN_MODE_MOVE @"Moving"
#define BTN_MODE_VIEW @"Viewing"

#define DS_PI 3.14159265359f
#define DS_RAD2DEG 180.0f/DS_PI
#define DS_DEG2RAD DS_PI/180.0f

#define MAX_SPEED 100.0f
#define TEXTURE_NAME @"sphere_texture1.png"

// see http://sohowww.nascom.nasa.gov/data/realtime-images.html
#define LATEST_SUN_URL @"http://sohowww.nascom.nasa.gov/data/realtime/eit_304/512/latest.jpg"

@implementation MainViewController

@synthesize point, sun, joystick;

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
    [self.view sendSubviewToBack:sm3dar.view];
    
    self.joystick = [[[Joystick alloc] initWithBackground:[UIImage imageNamed:@"128_white.png"]] autorelease];
    joystick.center = CGPointMake(160, 406);
    [self.view addSubview:joystick];
    
    [NSTimer scheduledTimerWithTimeInterval:0.10f target:self selector:@selector(updateJoystick) userInfo:nil repeats:YES];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];  
    
}

- (SM3DAR_PointOfInterest*)addPOI:(NSString*)title latitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lon  canReceiveFocus:(BOOL)canReceiveFocus {
    SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedSM3DAR_Controller];
    NSDictionary *poiProperties = [NSDictionary dictionaryWithObjectsAndKeys: 
                                   title, @"title",
                                   @"", @"subtitle",
                                   @"RoundedLabelMarkerView", @"view_class_name",
                                   [NSNumber numberWithDouble:lat], @"latitude",
                                   [NSNumber numberWithDouble:lon], @"longitude",
                                   sm3dar.currentLocation.altitude, @"altitude",
                                   nil];
    
    SM3DAR_PointOfInterest *poi = [[sm3dar initPointOfInterest:poiProperties] autorelease];    
    poi.canReceiveFocus = canReceiveFocus;
    [sm3dar addPointOfInterest:poi];
    return poi;
}

- (SM3DAR_Fixture*)fixtureAtCoordinate:(Coord3D)coord {
    SM3DAR_Fixture *fixture = [[[SM3DAR_Fixture alloc] init] autorelease];
    
    // TODO: set fixture's location
    [fixture translateX:coord.x Y:coord.y Z:coord.z];
    
    return fixture;
}

- (SM3DAR_Fixture*)sphereAtCoordinate:(Coord3D)coord textureName:(NSString*)textureName {
    SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedSM3DAR_Controller]; 

    // create point
    SM3DAR_Fixture *sphere = [self fixtureAtCoordinate:coord];
    
    // give point a view
    SphereView *sphereView = [[SphereView alloc] initWithTextureNamed:textureName];
    sphere.view = sphereView;  
    [sm3dar addPoint:sphere];
    [sphereView release];

    NSLog(@"Added sphere at %.1f, %.1f, %.1f", coord.x, coord.y, coord.z);
    return sphere;
}

- (void)loadPointsOfInterest {
    // add point
    SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedSM3DAR_Controller]; 
    
    CLLocationCoordinate2D currentLoc = [sm3dar currentLocation].coordinate;
    CLLocationDegrees lat=currentLoc.latitude;
    CLLocationDegrees lon=currentLoc.longitude;
    
    [self addPOI:@"N" latitude:(lat+0.01f) longitude:lon canReceiveFocus:NO];
    [self addPOI:@"S" latitude:(lat-0.01f) longitude:lon canReceiveFocus:NO];
    [self addPOI:@"E" latitude:lat longitude:(lon+0.01f) canReceiveFocus:NO];
    [self addPOI:@"W" latitude:lat longitude:(lon-0.01f) canReceiveFocus:NO];

    // create the initial sphere
	Coord3D coord = { 0, 0, 0 };
    NSString *textureName = nil;
    self.point = [self sphereAtCoordinate:coord textureName:textureName];

    // let there be light
    Coord3D sunCoord = [sm3dar solarPositionScaled:1200.0f];
    self.sun = [self sphereAtCoordinate:sunCoord textureName:LATEST_SUN_URL];

    // activate the joystick
    [NSTimer scheduledTimerWithTimeInterval:0.10f target:self selector:@selector(moveObject) userInfo:nil repeats:YES];    
}

- (CGFloat)computeSpeedFromAngle:(CGFloat)degrees {
    CGFloat maxSpeed = 2.0f;
    CGFloat speed = 0;
    
    speed = degrees / 90.0f * maxSpeed;
    
    //  if (degrees < 0.0f)
    //    speed *= -1.0f;
    
    return speed;
}

/*
 -(void)didChangeOrientationYaw:(CGFloat)yaw pitch:(CGFloat)pitch roll:(CGFloat)roll {
 SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedSM3DAR_Controller];
 if (!moveMode) {
 return;
 }
 
 // orientation values are in degrees
 // 90 is full bore
 
 CGFloat x=0, y=0, z=0;
 
 x = [self computeSpeedFromAngle:roll];
 y = 0; //[self computeSpeedFromAngle:pitch];
 z = [self computeSpeedFromAngle:pitch];
 
 //  [sm3dar debug:[NSString stringWithFormat:@"translate X: %f \nY: %f \nZ: %f", x, y, z]];
 //  [sm3dar debug:[NSString stringWithFormat:@"Y: %i \nP: %i \nR: %i", (int)yaw, (int)pitch, (int)roll]];
 
 [point translateX:x y:y z:z];
 
 Coord3D c = point.worldPoint;
 [sm3dar debug:[NSString stringWithFormat:@"X: %i \nY: %i \nZ: %i", (int)c.x, (int)c.y, (int)c.z]];
 }
 */

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
    [sun release];
    [joystick release];
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation 
{
    NSLog(@"location updated");
    [manager stopUpdatingLocation];
}

- (IBAction)toggleMode:(UIButton*)button {
    moveMode = !moveMode;
    NSString *titleText = (moveMode ? BTN_MODE_MOVE : BTN_MODE_VIEW);
    [button setTitle:titleText forState:UIControlStateNormal];
}

- (void)moveObject {
}

#pragma mark Joystick

//function to apply a velocity to a position with delta
static CGPoint applyVelocity(CGPoint velocity, CGPoint position, float delta){
	return CGPointMake(position.x + velocity.x * delta, position.y + velocity.y * delta);
}

#pragma mark -

- (void) updateJoystick {
    [joystick updateThumbPosition];
    
    CGFloat xspeed = joystick.velocity.x * MAX_SPEED;
    CGFloat yspeed = joystick.velocity.y * MAX_SPEED;
    
    if (abs(xspeed) > 0.0 || abs(yspeed) > 0.0) {
        [point translateX:xspeed Y:-yspeed Z:0];
        point.view.transform = CGAffineTransformRotate(point.view.transform, (DS_DEG2RAD*10));
    }
}

- (void) logoWasTapped {
    NSLog(@"toggling texture");
    
    SphereView *sphereView = (SphereView*)point.view;
    
    if (sphereView.textureImage) {
        // make wireframe
        [sphereView loadWireframe];
        
    } else {
        // add texture
        [sphereView setTextureWithImageNamed:TEXTURE_NAME];
    }
    
}


@end

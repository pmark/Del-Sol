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
#import "WireframeGridView.h"

#define DEG2RAD(A)			((A) * 0.01745329278)
#define RAD2DEG(A)			((A) * 57.2957786667)

#define BTN_MODE_MOVE @"Moving"
#define BTN_MODE_VIEW @"Viewing"

#define DS_PI 3.14159265359f
#define DS_RAD2DEG 180.0f/DS_PI
#define DS_DEG2RAD DS_PI/180.0f
#define PLACEHOLDER_TAG 12345
#define VIEW_TAG_BASE 10000
#define ALTITUDE_INTERVAL_METERS 10

#define MAX_SPEED 200.0f
#define TEXTURE_NAME @"sphere_texture1.png"

// see http://sohowww.nascom.nasa.gov/data/realtime-images.html
#define LATEST_SUN_URL @"http://sohowww.nascom.nasa.gov/data/realtime/eit_304/512/latest.jpg"

@implementation MainViewController

@synthesize point, sun, joystick;

// context aware
// semantic web
// senser nets
// ambient computing

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        urls = [[NSArray alloc] initWithObjects:
				@"http://bordertownlabs.com/spotmetrix/clocks/canvas_clock.html",
                @"http://m.flickr.com/#/photos/pmark/",
                @"http://bordertownlabs.com/spotmetrix/google_docs.png",
                @"http://media.chikuyonok.ru/ambilight/",
                nil];
        urlIndex = 0;
        
        panos = [[NSArray alloc] initWithObjects:
                 @"nakano-broadway.jpg",
                 @"international-forum.jpg",
                 @"tube-and-sushi.jpg",
                 @"gate-of-narita-san.jpg",
                nil];
        panoIndex = 0;
        
        placeholders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString*) keyForWebView:(UIWebView*)wv {
    return [NSString stringWithFormat:@"%i", [wv hash]];
}

- (UIWebView*)initWebView {
    NSString *url = [urls objectAtIndex:urlIndex++];
    if (urlIndex >= [urls count])
        urlIndex = 0;
    
    UIWebView *wv = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    [wv loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    wv.scalesPageToFit = YES;
    wv.opaque = NO;
    wv.backgroundColor = [UIColor clearColor];
    wv.hidden = NO;
    wv.delegate = self;
    [self.view addSubview:wv];
    [wv release];
    
    return wv;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.multipleTouchEnabled = YES;
    
    sm3dar = SM3DAR;
    sm3dar.farClipMeters = 100000.0;
    sm3dar.delegate = self;
    [self.view addSubview:sm3dar.view];    
    sm3dar.view.backgroundColor = [UIColor blackColor];
    
    self.joystick = [[[Joystick alloc] initWithBackground:[UIImage imageNamed:@"128_white.png"]] autorelease];
    joystick.center = CGPointMake(160, 406);
    [self.view addSubview:joystick];
    
    [NSTimer scheduledTimerWithTimeInterval:0.10f target:self selector:@selector(updateJoystick) userInfo:nil repeats:YES];    

    [self.view becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];  
    [self becomeFirstResponder];    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)selectedPointIsAtOrigin {
    Coord3D coord = self.point.worldPoint;
    return (coord.x == 0.0 && coord.y == 0.0 && coord.z == 0.0);
}

- (void)useWand {
    switch (wandType) {
        case WandTypeSphere:
            [self createSphere];
            break;
        case WandTypeImage:
            [self createImage];
            break;
        case WandTypeWeb:
            [self createWebView];
            break;
        default:
            [self createSphere];
            break;
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	[super motionBegan: motion withEvent: event];
	if (motion == UIEventSubtypeMotionShake) {        
        [self useWand];
    }
}

- (SM3DAR_PointOfInterest*)addPOI:(NSString*)title latitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lon  canReceiveFocus:(BOOL)canReceiveFocus {
    SM3DAR_PointOfInterest *poi = [[sm3dar initPointOfInterest:lat longitude:lon altitude:0 title:title subtitle:@"" markerViewClass:[RoundedLabelMarkerView class] properties:nil] autorelease];    
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

- (SM3DAR_Fixture*)billboardAtCoordinate:(Coord3D)coord view:(UIView*)billboardView {

    // create point
    SM3DAR_Fixture *fixture = [self fixtureAtCoordinate:coord];
    
    // give point a view
    SM3DAR_PointView *billboard = [[SM3DAR_PointView alloc] initWithFrame:
                                   CGRectMake(0, 0, 
                                              billboardView.bounds.size.width, 
                                              billboardView.bounds.size.height)];

    billboard.point = fixture;
    
    [billboard addSubview:billboardView];
    
    fixture.view = billboard;  
    [sm3dar addPoint:fixture];
    [billboard release];
    
    NSLog(@"Added billboard at %.1f, %.1f, %.1f", coord.x, coord.y, coord.z);
    return fixture;
}

- (void)createWireframeGrid {
    CLLocation *location = sm3dar.currentLocation;
	SM3DAR_PointOfInterest *grid = [sm3dar initPointOfInterest:location.coordinate.latitude 
                                                     longitude:location.coordinate.longitude 
                                                      altitude:location.altitude 
                                                         title:@"grid" 
                                                      subtitle:nil 
                                               markerViewClass:[WireframeGridView class] 
                                                    properties:nil];
    grid.canReceiveFocus = NO;
    [sm3dar addPointOfInterest:grid];
}

- (void)loadPointsOfInterest {
    // let there be light
    UIImage *img = [UIImage imageNamed:@"sun.jpg"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:img];
    
    Coord3D sunCoord = [sm3dar solarPositionScaled:200.0f];
//    Coord3D sunCoord = {
//        -100,
//        -200,
//        1000
//    };

    self.sun = [self billboardAtCoordinate:sunCoord view:iv];
    [iv release];
    
    // add point
    CLLocationCoordinate2D currentLoc = [sm3dar currentLocation].coordinate;
    CLLocationDegrees lat = currentLoc.latitude;
    CLLocationDegrees lon = currentLoc.longitude;
    
    [self addPOI:@"N" latitude:(lat+0.01f) longitude:lon canReceiveFocus:NO];
    [self addPOI:@"S" latitude:(lat-0.01f) longitude:lon canReceiveFocus:NO];
    [self addPOI:@"E" latitude:lat longitude:(lon+0.01f) canReceiveFocus:NO];
    [self addPOI:@"W" latitude:lat longitude:(lon-0.01f) canReceiveFocus:NO];

    // create the initial sphere
    //    [self createSphere];

    //[self createWireframeGrid];
    
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
 SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedController];
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
    [webView release];
    [urls release];
    [placeholders release];
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

- (void) updateJoystick2 {
    [joystick updateThumbPosition];
    
    Coord3D ray = [sm3dar ray:CGPointMake(160, 240)];    
    Coord3D unitPoint = [point unitVectorFromOrigin];
    CGPoint rayDiff = CGPointMake(unitPoint.x - ray.x, 
                                  unitPoint.y - ray.y);
    
//    CGFloat rayRadians = atan2(ray.y, ray.x);
//    CGFloat pointRadians = atan2(point.worldPoint.y, point.worldPoint.x);
//    CGFloat diffRadians = atan2(rayDiff.y, rayDiff.x);
    
    //NSLog(@"rayDiff: %.1f, %.1f : %.1f", rayDiff.x, rayDiff.y, RAD2DEG(diffRadians));
    
//    CGFloat relRadians = rayRadians - pointRadians;
//    CGFloat relDegrees = RAD2DEG(relRadians); 
//    CGPoint relRay = CGPointMake(cos(relRadians), sin(relRadians));
//    NSLog(@"Ray:%.1f, Point:%.1f, Rel:%.1f", RAD2DEG(rayRadians), RAD2DEG(pointRadians), relDegrees);
//    NSLog(@"Point: %.1f, %.1f : %.1f", unitPoint.x, unitPoint.y, RAD2DEG(pointRadians));
    
    CGFloat xspeed = (joystick.velocity.x * rayDiff.x) * MAX_SPEED;
    CGFloat yspeed = (joystick.velocity.y * abs(unitPoint.y)) * MAX_SPEED;
    
    if (abs(xspeed) > 0.0 || abs(yspeed) > 0.0) {

        // Joystick angles
        // Right: 0
        // Up: 90
        // Left: 180 / -180
        // Down: -90
        //CGFloat joystickDegrees = -RAD2DEG(atan2(joystick.velocity.y, joystick.velocity.x));
        

        // Ray angles
        // East: 0
        // North: 90
    	// West: 180 / -180
        // South: -90
		//NSLog(@"RAY ANGLE: %.2f", rayDegrees);        
        
//		NSLog(@"JOYSTICK ANGLE: %.2f", joystickegrees);        
		//NSLog(@"Translate %.2f, %.2f", xspeed, yspeed);        
        
        [point translateX:xspeed Y:-yspeed Z:0];
    }
}

- (void) updateJoystick {
    [joystick updateThumbPosition];
    
    CGFloat xspeed = joystick.velocity.x * MAX_SPEED;
    CGFloat yspeed = joystick.velocity.y * MAX_SPEED;
    
    //    double yawDegrees = SM3DAR.currentYaw;
    //    double yawRadians = DEG2RAD(yawDegrees);
    //    xspeed *= sin(yawRadians);
    //    yspeed *= cos(yawRadians);
    
    if (abs(xspeed) > 0.0 || abs(yspeed) > 0.0) {
        [point translateX:xspeed Y:-yspeed Z:0];
    }
}

- (void) elevatePoint {
    [point translateX:0 Y:0 Z:ALTITUDE_INTERVAL_METERS];
}

- (void) toggleSphereTexture {
    NSLog(@"toggling texture");
    
    if (![point.view isKindOfClass:[SphereView class]]) return;
    
    SphereView *sphereView = (SphereView*)point.view;
    
    if (sphereView.textureImage) {
        // make wireframe
        [sphereView loadWireframe];
        
    } else {
        // add texture
        [sphereView setTextureWithImageNamed:TEXTURE_NAME];
    }
}

- (void) logoWasTapped {
    //[self toggleSphereTexture];    
    
    // change what happens on shake
    wandType++;

    if (wandType > WAND_TYPE_COUNT) 
        wandType = 0;
    
    NSLog(@"New wand type: %i", wandType);
}

- (void)createWebView {
    NSLog(@"Creating webview at origin");
    Coord3D origin = [self spawnPoint];
    
    UIWebView *wv = [self initWebView];

    UIImage *img = [UIImage imageNamed:@"spiderweb_320x320.png"];
    UIImageView *placeholder = [[UIImageView alloc] initWithImage:img];
    NSLog(@"adding placeholder with tag %i", placeholder.tag);
    SM3DAR_Fixture *pf = [self billboardAtCoordinate:origin view:placeholder];
    NSString *key = [self keyForWebView:wv];
    [placeholders setValue:pf forKey:key];    
    
    self.point = [self billboardAtCoordinate:origin view:wv];
    //[wv release];
    
    CGFloat shrinker = 0.1;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationRepeatCount:100000];
    [UIView setAnimationRepeatAutoreverses:YES];
    
    placeholder.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.75, shrinker), 
                                                    CGAffineTransformMakeRotation(179));
    
    [UIView commitAnimations];
}

- (void)createSphere {
    NSLog(@"Creating sphere at origin");
    NSString *textureName = [panos objectAtIndex:panoIndex++];
    if (panoIndex >= [panos count]) {
        panoIndex = 0;
    }
        
    self.point = [self sphereAtCoordinate:[self spawnPoint] textureName:textureName];    
}

- (void)createImage {
    NSLog(@"Creating image at origin");
    UIImage *img = [UIImage imageNamed:@"Icon.png"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:img];
    self.point = [self billboardAtCoordinate:[self spawnPoint] view:iv];
    [iv release];
}

- (Coord3D)spawnPoint {
    
    double scalar = 3000.0;

    Coord3D ray = [sm3dar ray:CGPointMake(160, 240)];
    
    Coord3D coord = {
        ray.x * scalar,
    	ray.y * scalar,
        0
    };
    
    return coord;
    
#if 0    
    double yawDegrees = sm3dar.currentYaw;

    // need to correct yaw 
    double screenRadians = [sm3dar screenOrientationRadians];
    double screenDegrees = RAD2DEG(screenRadians);
    double yawRadians = DEG2RAD(yawDegrees);
    
    Coord3D coord = {
        sin(yawRadians) * scalar,
    	cos(yawRadians) * scalar,
        0
    };
    
    NSLog(@"Spawn point (at yaw %.1f, screen %.1f): %.1f, %.1f, %.1f", yawDegrees, screenDegrees, coord.x, coord.y, coord.z);
    
    return coord;
#endif
}

- (void)webViewDidStartLoad:(UIWebView *)wv {
    // display placeholder
    NSLog(@"webview loading");
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    NSLog(@"webview failed");    
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    NSLog(@"webview finished");
    NSString *key = [self keyForWebView:wv];
    SM3DAR_Fixture *pf = (SM3DAR_Fixture*)[placeholders objectForKey:key];    
    [pf.view removeFromSuperview];
    [sm3dar removePointOfInterest:pf];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] > 1) {
        [self useWand];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger fingers = [[event allTouches] count];
    if (fingers == 1)
        [point translateX:0 Y:0 Z:ALTITUDE_INTERVAL_METERS];        
    else if (fingers == 2)
        [point translateX:0 Y:0 Z:-ALTITUDE_INTERVAL_METERS];        
    
}

@end

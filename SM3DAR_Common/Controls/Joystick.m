//
//  Joystick.m
//  PointAndTilt
//
//  Created by P. Mark Anderson on 2/21/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#define SJ_PI 3.14159265359f
#define SJ_PI_X_2 6.28318530718f
#define SJ_RAD2DEG 180.0f/SJ_PI
#define SJ_DEG2RAD SJ_PI/180.0f

#define THUMB_HIDE_DELAY 2.0f

#import "Joystick.h"
#import "CGPointUtil.h"

@interface Joystick(hidden)
- (void)updateVelocity:(CGPoint)point;
- (void)resetJoystick;
@end

@implementation Joystick

@synthesize
thumb,
background,
stickPosition,
degrees,
velocity,
autoCenter,
isDPad,
active,
numberOfDirections,
joystickRadius,
thumbRadius,
deadRadius;

- (void) dealloc {
  [thumb release];
  [background release];
	[super dealloc];
}

- (void) updateThumbPosition {
  thumb.center = self.stickPosition;
}

-(void)updateVelocity:(CGPoint)point {
	// Calculate distance and angle from the center.
	float dx = point.x;
	float dy = point.y;
	float dSq = dx * dx + dy * dy;
  //NSLog(@"updateVelocity with point at %f, %f", dx, dy);  
  
	if (dSq <= deadRadiusSq) {
		velocity = CGPointZero;
		degrees = 0.0f;
		stickPosition = point;
		return;
	}
  
	float angle = atan2f(dy, dx); // in radians
	if (angle < 0){
		angle		+= SJ_PI_X_2;
	}
  
	float cosAngle;
	float sinAngle;
  
	if (isDPad) {
		float anglePerSector = 360.0f / numberOfDirections * SJ_DEG2RAD;
		angle = roundf(angle/anglePerSector) * anglePerSector;
	}
  
	cosAngle = cosf(angle);
	sinAngle = sinf(angle);
  
	// NOTE: Velocity goes from -1.0 to 1.0.
	if (dSq > joystickRadiusSq || isDPad) {
		dx = cosAngle * joystickRadius;
		dy = sinAngle * joystickRadius;
	}
  
	velocity = CGPointMake(dx/joystickRadius, dy/joystickRadius);
	degrees = angle * SJ_RAD2DEG;
  
	// Update the thumb's position
  //NSLog(@"stick: %f, %f", dx, dy);  
	stickPosition = CGPointMake(dx, dy);
  [self updateThumbPosition];
}

- (void) setJoystickRadius:(float)r
{
	joystickRadius = r;
	joystickRadiusSq = r*r;
}

- (void) setThumbRadius:(float)r
{
	thumbRadius = r;
	thumbRadiusSq = r*r;
}

- (void) setDeadRadius:(float)r
{
	deadRadius = r;
	deadRadiusSq = r*r;
}

- (void)resetJoystick {
  NSLog(@"RESET JOYSTICK TO: %f, %f", self.center.x, self.center.y);  
  degrees = 0.0f;
  velocity = CGPointZero;
  self.thumb.center = self.center;
  [self performSelector:@selector(hideThumb) withObject:nil afterDelay:THUMB_HIDE_DELAY];
}

- (void)setBackgroundAndFrame:(UIImage*)image {
  self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
  self.background = [[UIImageView alloc] initWithImage:image];
}

-(void)setup {
  NSLog(@"setup");
  
  self.backgroundColor = [UIColor clearColor];
  if (!background) {
    [self setBackgroundAndFrame:[UIImage imageNamed:@"128_white.png"]];
    [self addSubview:background];
  }
 
  if (!isDPad) {
    self.thumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"84_white.png"]];
    thumb.backgroundColor = [UIColor clearColor];
    thumb.hidden = NO;
    thumb.center = self.center;
    [self addSubview:thumb];
  }
  
  stickPosition = CGPointZero;
  degrees = 0.0f;
  velocity = CGPointZero;
  self.autoCenter = YES;
  self.isDPad = NO;
  self.numberOfDirections = 4; 
  self.joystickRadius = self.frame.size.width/2;
  self.thumbRadius = 32.0f;
  self.deadRadius = 10.0f;
}

- (id)initWithBackground:(UIImage*)image {  
  NSLog(@"initWithBackground");
	if (self = [super init]) {
    [self setBackgroundAndFrame:image];
		[self addSubview:background];
    [self setup];    
  }  
  return self;
}

// make 0, 0 be in the middle
- (CGPoint)centeredTouchLocation:(UITouch*)touch {
  CGPoint location = [touch locationInView:[touch view]];
  CGFloat w = self.frame.size.width;
  CGFloat h = self.frame.size.height;
  return CGPointMake(location.x - w/2.0f, location.y - h/2.0f);  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  NSLog(@"[Joystick] touchesBegan");
  [Joystick cancelPreviousPerformRequestsWithTarget:self];
  self.thumb.hidden = NO;
  UITouch *touch = [touches anyObject];
	CGPoint location = [self centeredTouchLocation:touch];

	//Do a fast rect check before doing a circle hit check:
	if(location.x < -joystickRadius || location.x > joystickRadius || location.y < -joystickRadius || location.y > joystickRadius){
		return;

	} else {
		float dSq = location.x*location.x + location.y*location.y;
		if(joystickRadiusSq > dSq){
			[self updateVelocity:location];
			return;
		}
	}
	return;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
  self.thumb.hidden = NO;
  UITouch *touch = [touches anyObject];
	CGPoint location = [self centeredTouchLocation:touch];
	[self updateVelocity:location];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  NSLog(@"[Joystick] touchesEnded");
  UITouch *touch = [touches anyObject];
	CGPoint location = CGPointZero;

	if (!autoCenter) {
    location = [self centeredTouchLocation:touch];
	}
	[self updateVelocity:location];
  
  [self resetJoystick];
}

- (void) hideThumb {
  self.thumb.hidden = YES;
}

@end

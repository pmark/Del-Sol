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
    WandTypeWeb,
    WandTypeSphere,
    WandTypeImage
} WandType;
#define WAND_TYPE_COUNT 3

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, SM3DAR_Delegate, CLLocationManagerDelegate, UIWebViewDelegate> {
    SM3DAR_Point *point;
    SM3DAR_Point *sun;
    BOOL moveMode;
    Joystick *joystick;
    WandType wandType;
    UIWebView *webView;
    NSArray *urls;
    NSInteger urlIndex;

    NSArray *panos;
    NSInteger panoIndex;

    
    NSUInteger viewTagIndex;
    NSMutableDictionary *placeholders;
	SM3DAR_Controller *sm3dar;
}

@property (nonatomic, retain) SM3DAR_Point *point;
@property (nonatomic, retain) SM3DAR_Point *sun;
@property (nonatomic, retain) Joystick *joystick;

- (IBAction)showInfo;
- (IBAction)toggleMode:(UIButton*)button;

- (SM3DAR_Fixture*)sphereAtCoordinate:(Coord3D)coord textureName:(NSString*)textureName;
- (SM3DAR_Fixture*)billboardAtCoordinate:(Coord3D)coord view:(UIView*)billboardView;
- (void)createWebView;
- (void)createSphere;
- (void)createImage;
- (BOOL)selectedPointIsAtOrigin;
- (Coord3D)spawnPoint;
@end

//
//  TexturedGeometryView.mm
//
//  Created by P. Mark Anderson on 2/23/10.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "TexturedGeometryView.h"


@implementation TexturedGeometryView

@synthesize zrot, color, geometry, texture, textureName, textureURL, artworkFetcher, textureImage;

- (id) initWithTextureNamed:(NSString*)name {
    if (self = [super init]) {    
        if ([name hasPrefix:@"http://"] || [name hasPrefix:@"https://"]) {
            self.textureURL = [NSURL URLWithString:name];
        } else {
            self.textureName = name;
        }        
        
        [self setupGeometryAndTexture];
    }
    
    return self;
}

- (id) initWithTextureURL:(NSURL*)url {
    if (self = [super init]) {    
        self.textureURL = url;
        [self setupGeometryAndTexture];
    }
    return self;
}

- (void) setTextureWithImageNamed:(NSString*)imgName {
    self.textureName = imgName;
    NSLog(@"Loading texture named %@", textureName);
    self.textureImage = [UIImage imageNamed:textureName];    
    self.texture = [[Texture newTextureFromImage:textureImage.CGImage] autorelease];
}

- (void) dealloc {
    [color release];
    [geometry release];
    [texture release];
    [textureName release];
    [textureURL release];
    [artworkFetcher release];
    [textureImage release];
    [super dealloc];
}


#pragma mark -
/*
 // Subclasses should implement didReceiveFocus
 - (void) didReceiveFocus {
 }
 */

#pragma mark -
- (void) updateTexture {
    if (self.textureImage) {
        NSLog(@"[TexturedGeometryView] updating texture with %@", self.textureImage);
        self.texture = [[Texture newTextureFromImage:textureImage.CGImage] autorelease];
    }
}

- (void)artworkFetcher:(AsyncArtworkFetcher *)fetcher didFinish:(UIImage *)artworkImage {  
    [self updateImage:artworkImage];
}

- (void) updateImage:(UIImage*)img {
    NSLog(@"[TexturedGeometryView] downloaded image with dimensions: %f, %f", img.size.width, img.size.height);
    //img = [self resizeImage:img];
    //NSLog(@"[TexturedGeometryView] resized image: %f, %f", img.size.width, img.size.height);
    self.textureImage = img;
    [self updateTexture];
}

- (UIImage*) resizeImage:(UIImage*)originalImage {
    CGFloat newWidth = 1024;
    CGFloat newHeight = 512;
    
	CGPoint topCorner = CGPointMake(0, 0);
	CGSize targetSize = CGSizeMake(newWidth, newHeight);	
	
	UIGraphicsBeginImageContext(targetSize);	
	[originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	
	return result;	
}

- (void) fetchTextureImage:(NSURL*)url {
    if (self.artworkFetcher == nil) {
        self.artworkFetcher = [[[AsyncArtworkFetcher alloc] init] autorelease];
        artworkFetcher.delegate = self;
    }
    
    artworkFetcher.url = url;
    [artworkFetcher fetch];    
    NSLog(@"[TexturedGeometryView] fetching image at %@", url);
}  

// Subclasses should implement setupGeometryAndTexture
- (void) setupGeometryAndTexture {
}

// Subclasses should implement displayGeometry
- (void) displayGeometry {
}

- (void) drawInGLContext {
    [self displayGeometry];
}

@end

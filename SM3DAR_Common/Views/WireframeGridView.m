//
//  WireframeGridView.m
//
//  Created by P. Mark Anderson on 8/4/2010.
//  Copyright 2010 Spot Metrix, Inc. All rights reserved.
//

#import "WireframeGridView.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>

#define LINE_COUNT 100

@implementation WireframeGridView

- (void) buildView
{
}

- (void) drawInGLContext 
{
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    glDepthMask(false);
    glEnable(GL_DEPTH_TEST);
    
    glColor4f (.3,.3,.3, 1);
    
	glEnableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
	static float verts[LINE_COUNT][2][3];
	unsigned short indexes[LINE_COUNT][2];
    
	for (int i=0; i < LINE_COUNT; i++)
	{
		verts[i][0][0] = 0;
		verts[i][0][1] = i;
		verts[i][0][2] = 0.0;
		
		verts[i][1][0] = LINE_COUNT-1;
		verts[i][1][1] = i;
		verts[i][1][2] = 0.0;
		
		indexes[i][0] = 2*i;
		indexes[i][1] = 2*i+1;
	}
	
	glVertexPointer(3, GL_FLOAT, 0, verts);
	glDrawElements(GL_LINES, 2*LINE_COUNT, GL_UNSIGNED_SHORT, indexes);
	
	for (int i=0; i < LINE_COUNT; i++)
	{
		verts[i][0][0] = i;
		verts[i][0][1] = 0;
		verts[i][0][2] = 0.0;
		
		verts[i][1][0] = i;
		verts[i][1][1] = LINE_COUNT-1;
		verts[i][1][2] = 0.0;
		
		indexes[i][0] = 2*i;
		indexes[i][1] = 2*i+1;
	}
	
	glVertexPointer(3, GL_FLOAT, 0, verts);
	glDrawElements(GL_LINES, 2*LINE_COUNT, GL_UNSIGNED_SHORT, indexes);
    
    glDepthMask(true);
}

@end

//
//  NezZoomRotationView.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezBaseSceneView.h"


@interface NezZoomRotationView : NezBaseSceneView {
	UIPinchGestureRecognizer *pinch;
	
	CGPoint firstTouch;
	float orientation[4];
	float prevOrientation[4];
	
	int touchesDown;
	
	BOOL animating;
	float start[3];
	float end[3];
	CGPoint touchVelocity;
	float deltaQuat[4];
	
	float cameraVecX;
}

@end

//
//  AnimationEditorController.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "ZoomRotationController.h"
#import "NezPlaybackBarController.h"


@interface AnimationEditorController : ZoomRotationController <NezPlaybackBarControllerDelegate> {
	NezPlaybackBarController *playbackBarController;
	NezController *controllerWithFocus;
	NSMutableArray *controllerArray;
}

@end

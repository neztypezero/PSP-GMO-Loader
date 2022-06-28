//
//  SceneAnimationEditor.h
//  GmoLoader
//
//  Created by David Nesbitt on 9/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezScene.h"
#import "NezAnimatedModel.h"
#import "NezPlaybackBar.h"

@interface SceneAnimationEditor : NezScene {
	NezAnimatedModel *mainModel;
	int animationIndex;
	
	NezPlaybackBar *playbackBar;
}

-(void)incrementFrame;
-(void)decrementFrame;

@property (readonly) NezPlaybackBar *playbackBar;

@end

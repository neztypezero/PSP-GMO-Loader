//
//  NezPlaybackBarController.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/5/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezController.h"
#import "NezPlaybackBar.h"
#import "NezPlaybackBarControllerDelegate.h"

@interface NezPlaybackBarController : NezController {
	BOOL moved;
	NezPlaybackBar *playbackBar;
	
	id<NezPlaybackBarControllerDelegate> delegate;
	
}

-(id)initWithPlaybackBar:(NezPlaybackBar*)pbBar;

@property (nonatomic, retain) id<NezPlaybackBarControllerDelegate> delegate;

@end

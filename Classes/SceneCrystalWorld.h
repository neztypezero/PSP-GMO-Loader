//
//  SceneCrystalWorld.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/24/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezScene.h"
#import "NezAnimatedModel.h"

@interface SceneCrystalWorld : NezScene {
	NezBonedModel *worldModel;
	
	CGPoint spinVector;
	float spinDeceleration;
	float spinAngle;
}

@end

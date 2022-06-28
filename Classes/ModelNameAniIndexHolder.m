//
//  ModelAniIndexHolder.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/5/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "ModelNameAniIndexHolder.h"


@implementation ModelNameAniIndexHolder

-(id)initWithName:(NSString*)name Index:(int)index {
	if ((self = [super init])) {
		modelName = [name retain];
		animationIndex = index;
	}
	return self;
}

-(void)dealloc {
	[modelName release];
	[super dealloc];
}

@end

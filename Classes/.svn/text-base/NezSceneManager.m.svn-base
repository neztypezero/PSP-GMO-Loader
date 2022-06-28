//
//  NezSceneManager.m
//  GmoLoader
//
//  Created by David Nesbitt on 9/8/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <objc/runtime.h>

#import "NezSceneManager.h"

NezSceneManager *g_NezSceneManager;

@implementation NezSceneManager

+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_NezSceneManager = [[NezSceneManager alloc] init];
    }
}

+ (NezSceneManager*)instance {
	return(g_NezSceneManager);
}

- (id) init {
	if(self = [super init]) {
		currentScene = nil;
	}
	return self;
}

- (void) dealloc {
	if (currentScene) {
		[currentScene release];
	}
    [super dealloc];
}

-(NezScene*)loadScene:(NSString*)name {
	if (currentScene) {
		if ([name isEqual:[[currentScene class] getSceneName]]) {
			return currentScene;
		}
		[currentScene->controller invalidate];
		[currentScene release];
		currentScene = nil;
	}
	NSArray *classArray = [self getAllSceneClasses];

	for (Class classObject in classArray) {
		if ([name isEqual:[classObject getSceneName]]) {
			currentScene = [[classObject alloc] init];
			break;
		}
	}
	return currentScene;
}

-(NSArray*)getAllSceneClasses {
	NSMutableArray *classArray = [NSMutableArray arrayWithCapacity:16];

	int numClasses;
	Class * classes = NULL;
	
	classes = NULL;
	numClasses = objc_getClassList(NULL, 0);
	
	if (numClasses > 0 ) {
		classes = malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		for (int i=0; i<numClasses; i++) {
			if (class_getSuperclass(classes[i]) == [NezScene class]) {
				[classArray addObject:[classes[i] class]];
			}
		}
		free(classes);
	}
	return classArray;
}


@end

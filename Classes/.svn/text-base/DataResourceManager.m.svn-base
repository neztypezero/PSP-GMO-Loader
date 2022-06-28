//
//  DataResourceManager.m
//  NezFFModelViewer
//
//  Created by David Nesbitt on 2/14/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "DataResourceManager.h"
#import "GmoModelLoader.h"

NSLock *dataMutex;
DataResourceManager *g_DataResManager;

@implementation DataResourceManager

+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        g_DataResManager = [[DataResourceManager alloc] init];
		dataMutex=[NSLock new];
    }
}

+ (DataResourceManager*)instance {
	return(g_DataResManager);
}

- (id) init {
	if(self = [super init]) {
		modelDict = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	}
	return self;
}

-(NezBonedModel*)loadModel:(NSString*)name ofType:(NSString*)ext {
	[dataMutex lock];
	NSLog(@"%@", name);
	NezBonedModel *model = [modelDict objectForKey:name];
	if (!model) {
		NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext inDirectory:[ext uppercaseString]];
		if ([ext isEqual:@"gmo"]) {
			GmoModelLoader *gmoLoader = [[GmoModelLoader alloc] init];
			model = [gmoLoader loadFile:path];
			[gmoLoader release];
		}
		if (model) {
			[modelDict setObject:model forKey:name];
		}
	}
	[dataMutex unlock];
	return model;
}

- (void) dealloc {
	[self releaseAll];
	[modelDict release];

    [super dealloc];
}

- (void) releaseAll {
	[modelDict removeAllObjects];
}

@end

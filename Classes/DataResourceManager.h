//
//  DataResourceManager.h
//  NezFFModelViewer
//
//  Created by David Nesbitt on 2/14/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezBonedModel.h"

@class DataResourceManager;

@interface DataResourceManager : NSObject {
	NSMutableDictionary *modelDict;
}

+(DataResourceManager *)instance;

-(NezBonedModel*)loadModel:(NSString*)name ofType:(NSString*)ext;

-(void)releaseAll;

@end

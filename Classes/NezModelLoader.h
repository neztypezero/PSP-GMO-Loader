//
//  NezModelLoader.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/21/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NezModelLoader

//-(NezSkinnedModel*)loadFile:(NSString*)filePath;
-(id)loadFile:(NSString*)filePath;

@end

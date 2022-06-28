//
//  NezAnimationSelectionView.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezZoomRotationView.h"
#import "NezAnimatedModel.h"
#import "NezHaloModel.h"


@interface NezAnimationSelectionView : NezZoomRotationView {
	float smallCameraMat[16];
	
	NezBonedModel *modelData;
	NezAnimatedModel *mainModel;
	NezHaloModel **modelAnimationArray;
	int animationCount;
	int selectedAnimationIndex;
	float thumbWidth, thumbHeight;
	int thumbY;
	float scaledThumbWidth, scaledThumbHeight;
	float thumbnailOffset;
	NSString *modelName;
	BOOL isAutoZooming;
	BOOL autoZoomFlag;
	float autoZoomRate;
}

@property (readonly, nonatomic) int animationCount;
@property (readonly, nonatomic) float thumbWidth;
@property (readonly, nonatomic) float thumbHeight;
@property (nonatomic, setter=setThumbnailOffset:) float thumbnailOffset;
@property (nonatomic, setter=setSelectedAnimationIndex:) int selectedAnimationIndex;

@end

//
//  NezAnimationSelectionController.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezBaseSceneController.h"


@interface NezAnimationSelectionController : NezBaseSceneController <UIScrollViewDelegate> {
	UITapGestureRecognizer *singleTapRecognizer;
	UIScrollView *thumbnailScrollView;
}

@property (nonatomic, retain, setter=setThumbnailScrollView:) IBOutlet UIScrollView *thumbnailScrollView;

@end

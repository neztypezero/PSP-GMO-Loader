//
//  NezAnimationSelectionController.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezAnimationSelectionController.h"
#import "NezAnimationSelectionView.h"


@interface NezAnimationSelectionController (private)

-(void)scrollViewDidScroll:(UIScrollView*)scrollView;

@end

@implementation NezAnimationSelectionController

@synthesize thumbnailScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        singleTapRecognizer = nil;
    }
    return self;
}

-(void)setThumbnailScrollView:(UIScrollView*)scrollView {
	if (singleTapRecognizer) {
		[thumbnailScrollView removeGestureRecognizer:singleTapRecognizer];
	}
	singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
	[scrollView addGestureRecognizer:singleTapRecognizer];
	thumbnailScrollView = scrollView;
}

-(void)viewDidLayout {
	[super viewDidLayout];

	NezAnimationSelectionView *view = (NezAnimationSelectionView*)self.view;
	thumbnailScrollView.frame = CGRectMake(0, view.frame.size.height-view.thumbHeight, view.frame.size.width, view.thumbHeight);
	[thumbnailScrollView setContentSize:CGSizeMake(view.thumbWidth*view.animationCount, view.thumbHeight)];
}

-(void)didReceiveMemoryWarning {
   // Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
   
   // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
	[super viewDidUnload];
	self.thumbnailScrollView = nil;
}

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
	NezAnimationSelectionView *view = (NezAnimationSelectionView*)self.view;
	view.thumbnailOffset = thumbnailScrollView.contentOffset.x;
}

-(void)scrollViewTapped {
	CGPoint point = [singleTapRecognizer locationOfTouch:0 inView:thumbnailScrollView];
	NezAnimationSelectionView *view = (NezAnimationSelectionView*)self.view;
	view.selectedAnimationIndex = (int)((point.x)/view.thumbWidth);
}

- (void)dealloc {
	[super dealloc];
}


@end

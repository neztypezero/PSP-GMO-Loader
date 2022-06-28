    //
//  NezBaseSceneController.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/23/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezBaseSceneController.h"
#import "NezBaseSceneView.h"
#import "GmoLoaderAppDelegate.h"
#import "NezBaseSceneView.h"
#import "EAGLView.h"


@implementation NezBaseSceneController

@synthesize loadParams;

-(void)pushViewControllerWithNibName:(NSString*)nibName animated:(BOOL)isAnimated loadParameters:(id)params {
	NezBaseSceneController *controller = [[NSClassFromString(nibName) alloc] initWithNibName:nibName bundle:nil];
	controller.loadParams = params;
	[self.navigationController pushViewController:controller animated:isAnimated];
	[controller release];
}

- (void)viewDidLayout {
	GmoLoaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NezBaseSceneView *view = (NezBaseSceneView*)self.view;
	[view loadSceneWithContext:delegate.glView.context andArguments:loadParams];
	self.loadParams = nil;
}

-(void)viewWillAppear:(BOOL)animated {
	NezBaseSceneView *view = (NezBaseSceneView*)self.view;
	GmoLoaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	delegate.glView.animationFrameInterval = view.animationFrameInterval;
	[super viewWillAppear:animated];
}

-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed {
	NezBaseSceneView *view = (NezBaseSceneView*)self.view;
	[view updateWithTimeElapsed:timeElapsed];
}

@end

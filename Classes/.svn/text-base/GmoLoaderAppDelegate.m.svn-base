//
//  GmoLoaderAppDelegate.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/25/10.
//  Copyright NezSoft 2010. All rights reserved.
//

#import "GmoLoaderAppDelegate.h"
#import "EAGLView.h"
#import "NezModeSelectionController.h"
#import "NezBaseSceneView.h"
#import "NezBaseSceneController.h"

@implementation GmoLoaderAppDelegate

@synthesize window;
@synthesize glView;
@synthesize navigationController;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[window addSubview:navigationController.view];
    [glView startAnimation];
    return YES;
}

-(void)setAnimationFrameInterval:(NSInteger)frameInterval {
	[glView setAnimationFrameInterval:frameInterval];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [glView stopAnimation];
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    [glView startAnimation];
}

-(void)applicationWillTerminate:(UIApplication *)application {
    [glView stopAnimation];
}

-(void)viewDidLayout {
	NezBaseSceneController *controller = (NezBaseSceneController*)navigationController.visibleViewController;
	[controller viewDidLayout];
}

-(void)dealloc {
    self.window = nil;
    self.glView = nil;
	self.navigationController = nil;

    [super dealloc];
}

@end

//
//  GmoLoaderAppDelegate.h
//  GmoLoader
//
//  Created by David Nesbitt on 8/25/10.
//  Copyright NezSoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface GmoLoaderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

-(void)viewDidLayout;
-(void)setAnimationFrameInterval:(NSInteger)frameInterval;

@end


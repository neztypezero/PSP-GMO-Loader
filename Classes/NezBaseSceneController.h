//
//  NezBaseSceneController.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/23/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NezBaseSceneController : UIViewController {
	id loadParams;
}

@property (nonatomic, retain) id loadParams;

-(void)pushViewControllerWithNibName:(NSString*)viewController animated:(BOOL)isAnimated loadParameters:(id)params;
-(void)viewDidLayout;
-(void)updateWithTimeElapsed:(CFTimeInterval)timeElapsed;

@end

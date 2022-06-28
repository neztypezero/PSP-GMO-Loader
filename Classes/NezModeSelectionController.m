//
//  NezModeSelectionController.m
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import "NezModeSelectionController.h"
#import "NezCrystalWorldController.h"
#import "NezAnimationSelectionController.h"
#import "NezModeSelectionView.h"
#import "ModelNameAniIndexHolder.h"


@implementation NezModeSelectionController

-(IBAction)crystalWorld:(id)sender {
	[self pushViewControllerWithNibName:@"NezCrystalWorldController" animated:YES loadParameters:nil];
}

-(IBAction)animationSelection:(id)sender {
	NezModeSelectionView *view = (NezModeSelectionView*)self.view;
	ModelNameAniIndexHolder *modelInfo = [[ModelNameAniIndexHolder alloc] initWithName:view.currentModelName Index:0];
	[self pushViewControllerWithNibName:@"NezAnimationSelectionController" animated:YES loadParameters:modelInfo];
}

-(IBAction)cameraMode:(UISegmentedControl*)sender {
	NezModeSelectionView *view = (NezModeSelectionView*)self.view;
	view.cameraMode = sender.selectedSegmentIndex;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Top";
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    [super dealloc];
}


@end

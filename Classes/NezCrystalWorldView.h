//
//  NezCrystalWorldView.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/22/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NezZoomRotationView.h"
#import "NezBonedModel.h"


@interface NezCrystalWorldView : NezZoomRotationView {
	NezBonedModel *worldModel;
}

@end

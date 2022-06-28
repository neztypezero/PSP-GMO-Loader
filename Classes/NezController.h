//
//  NezController.h
//  GmoLoader
//
//  Created by David Nesbitt on 10/8/10.
//  Copyright 2010 NezSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NezController : NSObject {

}

-(void)initializeControllers;

-(BOOL)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
-(BOOL)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
-(BOOL)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
-(BOOL)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end

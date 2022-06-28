//
//  EAGLView.m
//  GmoLoader
//
//  Created by David Nesbitt on 8/25/10.
//  Copyright NezSoft 2010. All rights reserved.
//

#import "EAGLView.h"
#import "ES2Renderer.h"

#import "GmoLoaderAppDelegate.h"
#import "NezBaseSceneView.h"
#import "NezBaseSceneController.h"

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize context;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        renderer = [[ES2Renderer alloc] init];
        animating = FALSE;
        animationFrameInterval = 2;
        displayLink = nil;
		lastTime = 0;
	}
    return self;
}

-(EAGLContext*)getContext {
	return [renderer getContext];
}

- (void)drawView:(CADisplayLink*)sender {
	CFTimeInterval currentTime = sender.timestamp;
	if (lastTime > 0) {
		GmoLoaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		NezBaseSceneController *controller = (NezBaseSceneController*)delegate.navigationController.visibleViewController;
		NezBaseSceneView *view = (NezBaseSceneView*)controller.view;
		[controller updateWithTimeElapsed:currentTime-lastTime];
		[renderer render:view];
	}
	lastTime = currentTime;
}

- (void)layoutSubviews {
	static BOOL firstTime = YES;
	if (firstTime) {
		UIScreen *mainScreen = [UIScreen mainScreen];
		float scale = mainScreen.scale;
		float w = mainScreen.bounds.size.width;
		float h = mainScreen.bounds.size.height;
		float sw = w*scale;
		float sh = h*scale;
		self.frame = CGRectMake(0, 0, sw, sh);
		self.bounds = CGRectMake(0, 0, sw, sh);
		CGAffineTransform matrix = {
			1/scale, 0,
			0, 1/scale,
			(w-sw)/2, (h-sh)/2,
		};
		self.transform = matrix;
		
		[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
		firstTime = NO;
	}
}

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

-(void)setAnimationFrameInterval:(NSInteger)frameInterval {
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation {
    if (!animating) {
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
		[displayLink setFrameInterval:animationFrameInterval];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        animating = TRUE;
    }
}

- (void)stopAnimation {
    if (animating) {
		[displayLink invalidate];
		displayLink = nil;
        animating = FALSE;
    }
}

- (void)dealloc {
    [renderer release];
    [super dealloc];
}

@end

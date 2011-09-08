//
//  GameView.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"
#import "TriviaPlayer.h"

const CGFloat kGameViewTransitionTime = 0.5;
const CGFloat kGameViewPlayerDisplayTime = 4.0;

@interface QuicklyResizingConstraintManager : CAConstraintLayoutManager
@end

@implementation QuicklyResizingConstraintManager
- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	id old = [[CATransaction valueForKey:kCATransactionDisableActions] retain];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	[super layoutSublayersOfLayer:layer];

	[CATransaction setValue:old forKey:kCATransactionDisableActions];
	[old release];
}
@end

@implementation GameView

@synthesize delegate;
@synthesize players=_players;

- (void)awakeFromNib
{
	_rootLayer = [CALayer layer];
	_rootLayer.name = @"Root Layer";
	_rootLayer.layoutManager = [QuicklyResizingConstraintManager layoutManager];
	[self setLayer:_rootLayer];
	[self setWantsLayer:YES];
	CGColorRef bg = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
	_rootLayer.backgroundColor = bg;
	CGColorRelease(bg);

	_imageLayer = [CALayer layer];
	_imageLayer.name = @"Image Layer";
	_imageLayer.contentsGravity = kCAGravityResizeAspect;
	CIFilter* pixelate = [CIFilter filterWithName:@"CIPixellate"];
	pixelate.name = @"pixelate";
	[pixelate setDefaults];
	[pixelate setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputScale"];
	_imageLayer.filters = [NSArray arrayWithObject:pixelate];
	_imageLayer.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
	[_imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX offset:0.0]];
	[_imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX offset:0.0]];
	[_imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY offset:0.0]];
	[_imageLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY offset:0.0]];
	[_rootLayer addSublayer:_imageLayer];

	_playerLayer = [CALayer layer];
	_playerLayer.name = @"Player Layer";
	[_rootLayer addSublayer:_playerLayer];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	// If this is the animation we're looking for (probably is)...

	[self.delegate gameViewImageShown:self];
}

- (NSPoint)offScreenRight
{
	NSRect bounds = self.bounds;
	return NSMakePoint(bounds.size.width + bounds.size.width/2.0, bounds.size.height/2.0);
}

- (NSPoint)offScreenLeft
{
	NSRect bounds = self.bounds;
	return NSMakePoint(0.0 - bounds.size.width/2.0, bounds.size.height/2.0);
}

- (NSPoint)screenCenter
{
	return NSMakePoint(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
}

- (void)setImage:(NSImage *)theImage
{
	if(theImage == nil)
	{
		_imageLayer.contents = nil;
		return;
	}

	BOOL firstImage = YES;
	CGImageRef cgImage = [theImage CGImageForProposedRect:NULL context:nil hints:nil];
	if(_imageLayer.contents != nil)
	{
		firstImage = NO;
		// Show player scores first
		CAKeyframeAnimation* playerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		playerAnimation.duration = kGameViewTransitionTime*2.0 + kGameViewPlayerDisplayTime;
		playerAnimation.values = [NSArray arrayWithObjects:
								  [NSValue valueWithPoint:[self offScreenRight]],
								  [NSValue valueWithPoint:[self screenCenter]],
								  [NSValue valueWithPoint:[self screenCenter]],
								  [NSValue valueWithPoint:[self offScreenLeft]],
								  nil];
		playerAnimation.keyTimes = [NSArray arrayWithObjects:
									[NSNumber numberWithFloat:0.0],
									[NSNumber numberWithFloat:kGameViewTransitionTime/playerAnimation.duration],
									[NSNumber numberWithFloat:(kGameViewPlayerDisplayTime+kGameViewTransitionTime)/playerAnimation.duration],
									[NSNumber numberWithFloat:1.0],
									nil];
		playerAnimation.removedOnCompletion = NO;
		playerAnimation.fillMode = kCAFillModeForwards;
		playerAnimation.timingFunctions = [NSArray arrayWithObjects:
										   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
										   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
										   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
										   nil];
		[self showPlayers];

		CAKeyframeAnimation* imageOffAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		imageOffAnimation.values = [NSArray arrayWithObjects:
									[NSValue valueWithPoint:[self screenCenter]],
								    [NSValue valueWithPoint:[self offScreenLeft]],
								    nil];
		imageOffAnimation.duration = kGameViewTransitionTime;
		imageOffAnimation.timingFunctions = [NSArray arrayWithObjects:
											 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
											 nil];
		imageOffAnimation.removedOnCompletion = NO;
		imageOffAnimation.fillMode = kCAFillModeForwards;

		CAKeyframeAnimation* imageOnAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		imageOnAnimation.values = [NSArray arrayWithObjects:
								   [NSValue valueWithPoint:[self offScreenRight]],
								   [NSValue valueWithPoint:[self screenCenter]],
								   nil];
		imageOnAnimation.duration = kGameViewTransitionTime;
		imageOnAnimation.beginTime = kGameViewTransitionTime+kGameViewPlayerDisplayTime;
		imageOnAnimation.timingFunctions = [NSArray arrayWithObjects:
											[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
											nil];
		imageOnAnimation.removedOnCompletion = NO;
		imageOnAnimation.fillMode = kCAFillModeForwards;

		CAKeyframeAnimation* setImageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
		setImageAnimation.values = [NSArray arrayWithObjects:
									_imageLayer.contents,
									(id)cgImage,
									(id)cgImage,
									nil];
		setImageAnimation.keyTimes = [NSArray arrayWithObjects:
									  [NSNumber numberWithFloat:0.0],
									  [NSNumber numberWithFloat:0.5],
									  [NSNumber numberWithFloat:1.0],
									  nil];
		setImageAnimation.calculationMode = kCAAnimationDiscrete;
		setImageAnimation.duration = kGameViewTransitionTime*2.0 + kGameViewPlayerDisplayTime;
		setImageAnimation.removedOnCompletion = NO;
		setImageAnimation.fillMode = kCAFillModeForwards;

		CAKeyframeAnimation* pixelationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"filters.pixelate.inputScale"];
		pixelationAnimation.values = [NSArray arrayWithObjects:
									  [NSNumber numberWithFloat:1.0],
									  [NSNumber numberWithFloat:[[NSUserDefaults standardUserDefaults] floatForKey:@"startingBlockSize"]],
									  nil];
		pixelationAnimation.calculationMode = kCAAnimationDiscrete;
		// "* 2.0" because a discreet transition happens in the middle of the duration
		pixelationAnimation.duration = kGameViewTransitionTime*2.0;
		pixelationAnimation.fillMode = kCAFillModeForwards;

		CAAnimationGroup* imageGroup = [CAAnimationGroup animation];
		imageGroup.duration = kGameViewTransitionTime*2.0 + kGameViewPlayerDisplayTime;
		imageGroup.animations = [NSArray arrayWithObjects:imageOffAnimation, imageOnAnimation, setImageAnimation, pixelationAnimation, nil];
		imageGroup.delegate = self;

		[_imageLayer addAnimation:imageGroup forKey:@"presentImage"];
		[_playerLayer addAnimation:playerAnimation forKey:@"presentPlayers"];
	}

	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	_imageLayer.contents = (id)cgImage;
	[_imageLayer setValue:[NSNumber numberWithFloat:[[NSUserDefaults standardUserDefaults] floatForKey:@"startingBlockSize"]] forKeyPath:@"filters.pixelate.inputScale"];

	[CATransaction commit];

	if(firstImage)
	{
		[self animationDidStop:nil finished:YES];
	}
}

- (void)setPixelSize:(CGFloat)pixelSize
{
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	[_imageLayer setValue:[NSNumber numberWithFloat:pixelSize] forKeyPath:@"filters.pixelate.inputScale"];

	[CATransaction commit];
}

- (void)showPlayers
{
	NSRect bounds         = [self bounds];
	CGFloat width         = bounds.size.height;
	CGFloat sectionHeight = floorf(bounds.size.height/8.0);
	CGFloat playerHeight  = floorf(sectionHeight*0.8);
	NSMutableArray* sortedPlayers = [_players mutableCopy];
	[sortedPlayers sortUsingSelector:@selector(sortByPoints:)];

	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
	{
		_playerLayer.sublayers = nil;
		_playerLayer.bounds = CGRectMake(0.0, 0.0, bounds.size.height, bounds.size.height);
		_playerLayer.position = NSPointToCGPoint([self offScreenRight]);
	}
	[CATransaction commit];

	CGFloat i = 0.0;
	for(TriviaPlayer* aPlayer in sortedPlayers)
	{
		CALayer* bg = [CALayer layer];
		bg.bounds          = CGRectMake(0.0, 0.0, width, playerHeight);
		bg.position        = CGPointMake(width/2.0, bounds.size.height - (i*sectionHeight + playerHeight/2.0));
		bg.backgroundColor = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
		CGColorRelease(bg.backgroundColor);

		CATextLayer* nameLayer = [CATextLayer layer];
		nameLayer.font            = @"Helvetica-Bold";
		nameLayer.fontSize        = playerHeight;
		nameLayer.string          = [aPlayer name];
		nameLayer.foregroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
		nameLayer.backgroundColor = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
		nameLayer.frame           = CGRectMake(0.0, 0.0, width*0.7, playerHeight);
		nameLayer.alignmentMode   = kCAAlignmentLeft;
		nameLayer.truncationMode  = kCATruncationEnd;
		CGColorRelease(nameLayer.foregroundColor);
		CGColorRelease(nameLayer.backgroundColor);
		[bg addSublayer:nameLayer];

		CATextLayer* pointsLayer = [CATextLayer layer];
		pointsLayer.font            = @"Helvetica-Bold";
		pointsLayer.fontSize        = playerHeight;
		pointsLayer.string          = [NSString stringWithFormat:@"%d", [aPlayer points]];
		pointsLayer.foregroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
		pointsLayer.backgroundColor = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
		pointsLayer.frame           = CGRectMake(nameLayer.frame.size.width, 0.0, width-nameLayer.frame.size.width, playerHeight);
		pointsLayer.alignmentMode   = kCAAlignmentRight;
		CGColorRelease(pointsLayer.foregroundColor);
		CGColorRelease(pointsLayer.backgroundColor);
		[bg addSublayer:pointsLayer];

		[_playerLayer addSublayer:bg];
		i += 1.0;
	}
	[sortedPlayers release];
}

@end

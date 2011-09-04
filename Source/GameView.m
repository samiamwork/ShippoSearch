//
//  GameView.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameView.h"
#import <QuartzCore/QuartzCore.h>

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
	
}

- (void)setImage:(NSImage *)theImage
{
	CGImageRef cgImage = [theImage CGImageForProposedRect:NULL context:nil hints:nil];
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	_imageLayer.contents = (id)cgImage;

	[CATransaction commit];
	CGImageRelease(cgImage);
}

- (void)setPixelSize:(CGFloat)pixelSize
{
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];

	[_imageLayer setValue:[NSNumber numberWithFloat:pixelSize] forKeyPath:@"filters.pixelate.inputScale"];

	[CATransaction commit];
}

@end

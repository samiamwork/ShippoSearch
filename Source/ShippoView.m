//
//  ShippoView.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ShippoView.h"


@implementation ShippoView

- (id)initWithFrame:(NSRect)frame {
    if( (self = [super initWithFrame:frame]) ) {
		_scaleFilter = [[CIFilter filterWithName:@"CIAffineTransform"] retain];
		[_scaleFilter setDefaults];
		_pixelateFilter = [[CIFilter filterWithName:@"CIPixellate"] retain];
		[_pixelateFilter setDefaults];
		[_pixelateFilter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputScale"];
    }
    return self;
}

- (void)dealloc
{
	[_pixelateFilter release];
	[_scaleFilter release];

	[super dealloc];
}

- (void)recalculateScale
{
	if( ![self image] ) {
		[_scaleFilter setValue:[NSAffineTransform transform] forKey:@"inputTransform"];
		return;
	}
	
	// assume width of the window will always be greater than height
	NSSize viewSize = [self bounds].size;
	CGRect imageExtent = [[self image] extent];
	
	float scale = 1.0f;
	
	scale = viewSize.width/imageExtent.size.width;
	if( imageExtent.size.height*scale > viewSize.height )
		scale = viewSize.height/imageExtent.size.height;
	
	NSAffineTransform *scaleTransform = [NSAffineTransform transform];
	[scaleTransform scaleBy:scale];
	[_scaleFilter setValue:scaleTransform forKey:@"inputTransform"];
}

- (void)setPixelSize:(float)newPixelSize
{
	[_pixelateFilter setValue:[NSNumber numberWithFloat:newPixelSize] forKey:@"inputScale"];
	[self setNeedsDisplay:YES];
}
- (float)pixelSize
{
	return [[_pixelateFilter valueForKey:@"inputScale"] floatValue];
}

- (void)setImage:(CIImage *)theImage dirtyRect:(CGRect)theRect
{
	[super setImage:theImage dirtyRect:theRect];
	[self recalculateScale];
	
	[_scaleFilter setValue:[self image] forKey:@"inputImage"];
}

- (void)viewBoundsDidChange:(NSRect)bounds
{
	// adjust image scale
	[self recalculateScale];
}

- (void)drawRect:(NSRect)bounds inCIContext:(CIContext *)ctx
{
	if( ![self image] )
		return;
	
	[_pixelateFilter setValue:[_scaleFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
	CIImage *outputImage = [_pixelateFilter valueForKey:@"outputImage"];
	
	CGSize imageExtent = [[_scaleFilter valueForKey:@"outputImage"] extent].size;

	CGPoint imagePoint;
	imagePoint.x = floorf((bounds.size.width-imageExtent.width)/2.0f);
	imagePoint.y = floorf((bounds.size.height-imageExtent.height)/2.0f);
	[ctx drawImage:outputImage atPoint:imagePoint fromRect:*(CGRect *)&bounds];
}
@end

//
//  CIView.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreImage.h>

@interface CIView : NSOpenGLView {
	CIContext *_context;
	CIImage *_image;
	NSRect _lastBounds;
}

- (CIImage *)image;
- (void)setImage:(CIImage *)theImage dirtyRect:(CGRect)theRect;
- (void)setImage:(CIImage *)theImage;

@end

@interface NSObject (SampleCIViewDraw)
// If defined in the view subclass, called when rendering
- (void)drawRect:(NSRect)bounds inCIContext:(CIContext *)ctx;
@end

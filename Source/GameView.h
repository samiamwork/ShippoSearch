//
//  GameView.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GameView : NSView
{
	CALayer* _rootLayer;
	CALayer* _imageLayer;
	CGFloat  _pixelSize;
}

- (void)setImage:(NSImage *)theImage;
- (void)setPixelSize:(CGFloat)pixelSize;
@end

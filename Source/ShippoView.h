//
//  ShippoView.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CIView.h"

@interface ShippoView : CIView {
	CIFilter *_scaleFilter;
	CIFilter *_pixelateFilter;
}

- (void)setPixelSize:(float)newPixelSize;
- (float)pixelSize;
@end

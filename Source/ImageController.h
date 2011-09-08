//
//  ImageController.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/28/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ImageController : NSObject {
	IBOutlet NSTableView *_table;
	IBOutlet NSTextField *_imagesLeftLabel;
	
	NSString *_path;
	NSMutableArray *_images;
}

- (IBAction)setDirectory:(id)sender;

- (NSString *)getImage;
- (void)removeImage:(NSString *)stringToRemove;
@end

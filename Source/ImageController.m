//
//  ImageController.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/28/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ImageController.h"


@implementation ImageController

- (void)dealloc
{
	[_images release];
	[_path release];
	
	[super dealloc];
}

- (void)getImages
{
	[_images removeAllObjects];
	NSError* err;
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_path error:&err];
	
	NSArray *acceptedFileTypes = [NSImage imageFileTypes];
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *aFile;
	while( (aFile = [fileEnumerator nextObject]) ) {
		if( [acceptedFileTypes containsObject:[aFile pathExtension]] )
			[_images addObject:aFile];
	}
	[_imagesLeftLabel setStringValue:[NSString stringWithFormat:@"%d left", (int)[_images count]]];
}

- (void)awakeFromNib
{
	_images = [[NSMutableArray alloc] init];
	_path = [[@"~/Desktop" stringByExpandingTildeInPath] retain];
	[self getImages];
	[_table reloadData];
}

- (IBAction)setDirectory:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanCreateDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	
	if( [openPanel runModalForDirectory:_path file:nil] == NSCancelButton )
		return;
	
	NSString *newPath = [openPanel filename];
	if( !newPath )
		return;
	
	[_path release];
	_path = [newPath retain];
	[self getImages];
	[_table reloadData];
}

- (NSString *)getImage
{
	if( [_images count] == 0 )
		return nil;
	
	srand(time(NULL));
	unsigned int randomImageIndex = rand() % [_images count];
	NSString *imagePath = [_path stringByAppendingPathComponent:[_images objectAtIndex:randomImageIndex]];
	[_table selectRowIndexes:[NSIndexSet indexSetWithIndex:randomImageIndex] byExtendingSelection:NO];
	return imagePath;
}
- (void)removeImage:(NSString *)stringToRemove
{
	[_images removeObject:[stringToRemove lastPathComponent]];
	[_table reloadData];
	[_imagesLeftLabel setStringValue:[NSString stringWithFormat:@"%d left", (int)[_images count]]];
}

#pragma mark TableView Datasource Methods

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_images count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [_images objectAtIndex:rowIndex];
}

@end

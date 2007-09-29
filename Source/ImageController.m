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
	NSArray *files = [[NSFileManager defaultManager] directoryContentsAtPath:_path];
	
	NSArray *acceptedFileTypes = [NSImage imageFileTypes];
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *aFile;
	while( (aFile = [fileEnumerator nextObject]) ) {
		if( [acceptedFileTypes containsObject:[aFile pathExtension]] )
			[_images addObject:aFile];
	}
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
	return [_path stringByAppendingPathComponent:[_images objectAtIndex:[_table selectedRow]]];
}
- (void)removeImage:(NSString *)stringToRemove
{
	[_images removeObject:[stringToRemove lastPathComponent]];
	[_table reloadData];
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

//
//  PlayerController.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/28/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "PlayerController.h"


@implementation PlayerController

- (id)init
{
	if( (self = [super init]) ) {
		_players = [[NSMutableArray alloc] init];
		_pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(pollingTick:) userInfo:nil repeats:YES];
		_getInputController = [[TriviaPlayerGetInputController alloc] init];
		[[TIPInputManager defaultManager] setDelegate:self];
	}

	return self;
}

- (void)dealloc
{
	[_players release];
	[_pollingTimer invalidate];
	[_getInputController release];

	[super dealloc];
}

- (id)delegate
{
	return _delegate;
}
- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
}

- (void)pollingTick:(NSTimer *)theTimer
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSEnumerator *playerEnumerator = [_players objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		if( [aPlayer isButtonPressed] )
			break;
	}
	
	if( aPlayer && [_delegate respondsToSelector:@selector(playerBuzzed:)] )
		[_delegate playerBuzzed:aPlayer];
	
	[pool release];
}

- (void)reloadData
{
	[_table reloadData];
}

- (void)awakeFromNib
{
}

- (IBAction)addPlayer:(id)sender
{
	[_players addObject:[[[TriviaPlayer alloc] init] autorelease]];
	[_table reloadData];
}
- (IBAction)removePlayer:(id)sender
{
	[_players removeObjectAtIndex:[_table selectedRow]];
	[_table reloadData];
}
- (IBAction)setButton:(id)sender
{
	TriviaPlayer *thePlayer = [_players objectAtIndex:[_table selectedRow]];
	if( !thePlayer )
		return;
	
	[_getInputController setPromptStringForPlayerName:[thePlayer name]];
	[[TIPInputManager defaultManager] getAnyElementWithTimeout:10.0];
	
	[_getInputController beginModalStatus];
}

- (void)elementSearchFinished:(TIPInputElement *)foundElement
{
	TriviaPlayer *thePlayer = [_players objectAtIndex:[_table selectedRow]];
	if( foundElement && thePlayer )
		[thePlayer setInputElement:foundElement];
	
	[_getInputController endModalStatus];
	[_table reloadData];
}

- (void)setAllPlayersEnabled:(BOOL)willEnable;
{
	NSEnumerator *playerEnumerator = [_players objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) )
		[aPlayer setEnabled:willEnable];
}

#pragma mark TableView datasource Methods

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [_players count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	TriviaPlayer *thePlayer = [_players objectAtIndex:rowIndex];
	
	if( [[aTableColumn identifier] isEqualToString:@"status"] )
		return [thePlayer isConnected] ? [NSImage imageNamed:@"jewel green"] : [NSImage imageNamed:@"jewel red"];
	else if( [[aTableColumn identifier] isEqualToString:@"name"] )
		return [thePlayer name];
	else if( [[aTableColumn identifier] isEqualToString:@"score"] )
		return [NSNumber numberWithInt:[thePlayer points]];
	
	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	TriviaPlayer *thePlayer = [_players objectAtIndex:rowIndex];
	if( !thePlayer )
		return;
	
	if( [[aTableColumn identifier] isEqualToString:@"name"] )
		[thePlayer setName:anObject];
	else if( [[aTableColumn identifier] isEqualToString:@"score"] )
		[thePlayer setPoints:[(NSString *)anObject intValue]];
	
}

@end

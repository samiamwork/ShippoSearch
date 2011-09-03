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
		_getInputController = [[TriviaPlayerGetInputController alloc] init];
		[[TIPInputManager defaultManager] setDelegate:self];
	}

	return self;
}

- (void)dealloc
{
	[_players release];
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

- (void)reloadData
{
	[_table reloadData];
}

- (NSArray*)players
{
	return _players;
}

- (void)awakeFromNib
{
}

- (IBAction)addPlayer:(id)sender
{
	[self willChangeValueForKey:@"players"];
	[_players addObject:[[[TriviaPlayer alloc] init] autorelease]];
	[self didChangeValueForKey:@"players"];
}
- (IBAction)removePlayer:(id)sender
{
	[self willChangeValueForKey:@"players"];
	[_players removeObjectAtIndex:[_table selectedRow]];
	[self didChangeValueForKey:@"players"];
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

- (void)inputManager:(TIPInputManager *)inputManager elementPressed:(TIPInputElement *)element
{
	for(TriviaPlayer* aPlayer in _players)
	{
		if([aPlayer inputElement] == element)
		{
			[aPlayer setPressed:YES];
			if([aPlayer enabled] && _delegate != nil && [_delegate respondsToSelector:@selector(playerBuzzed:)])
			{
				[_delegate playerBuzzed:aPlayer];
			}
			break;
		}
	}
}

- (void)inputManager:(TIPInputManager *)inputManager elementReleased:(TIPInputElement *)element
{
	for(TriviaPlayer* aPlayer in _players)
	{
		if([aPlayer inputElement] == element)
		{
			[aPlayer setPressed:NO];
			break;
		}
	}
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

- (BOOL)allPlayersDisabled
{
	for(TriviaPlayer* aPlayer in _players)
	{
		if([aPlayer enabled])
		{
			return NO;
		}
	}
	return YES;
}

@end

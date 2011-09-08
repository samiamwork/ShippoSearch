//
//  PlayerController.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/28/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TriviaPlayer.h"
#import "TriviaPlayerGetInputController.h"
#import "TIPInputManager.h"

@interface PlayerController : NSObject<TIPInputManagerDelegate> {
	IBOutlet NSTableView *_table;
	NSMutableArray *_players;
	id _delegate;
	
	TriviaPlayerGetInputController *_getInputController;
}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (IBAction)setButton:(id)sender;
- (void)reloadData;

- (NSArray*)players;

- (void)setAllPlayersEnabled:(BOOL)willEnable;
- (BOOL)allPlayersDisabled;
@end

@interface NSObject (PlayerDelegate)
- (void)playerBuzzed:(TriviaPlayer *)thePlayer;
@end

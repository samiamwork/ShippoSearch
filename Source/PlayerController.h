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

@interface PlayerController : NSObject {
	IBOutlet NSTableView *_table;
	
	NSMutableArray *_players;
	NSTimer *_pollingTimer;
	
	id _delegate;
	
	TriviaPlayerGetInputController *_getInputController;
}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (IBAction)addPlayer:(id)sender;
- (IBAction)removePlayer:(id)sender;
- (IBAction)setButton:(id)sender;
- (void)reloadData;

- (void)setAllPlayersEnabled:(BOOL)willEnable;
@end

@interface NSObject (PlayerDelegate)
- (void)playerBuzzed:(TriviaPlayer *)thePlayer;
@end

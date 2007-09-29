//
//  ShippoSearchDelegate.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ShippoView.h"
#import "ImageController.h"
#import "PlayerController.h"
#import "FullscreenSheetController.h"

@interface ShippoSearchDelegate : NSObject
{
	IBOutlet ShippoView *_imageView;
	IBOutlet ImageController *_imageController;
	IBOutlet PlayerController *_playerController;
	IBOutlet NSTextField *_buzzedPlayerName;
	IBOutlet NSWindow *_gameWindow;
	
	FullscreenSheetController *_fullscreenController;
	
	NSTimer *_timer;
	NSAnimation *_animation;
	NSString *_imagePath;
	
	TriviaPlayer *_buzzedPlayer;
}

- (IBAction)nextImage:(id)sender;
- (IBAction)rightAnswer:(id)sender;
- (IBAction)wrongAnswer:(id)sender;
- (IBAction)fullscreen:(id)sender;
@end

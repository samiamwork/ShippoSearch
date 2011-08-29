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
#import "TIPFreeWindow.h"

@interface ShippoSearchDelegate : NSObject
{
	IBOutlet ShippoView *_imageView;
	IBOutlet ImageController *_imageController;
	IBOutlet PlayerController *_playerController;
	IBOutlet NSTextField *_buzzedPlayerName;
	IBOutlet TIPFreeWindow *_gameWindow;
	IBOutlet NSTextField *_pointValueField;
	IBOutlet NSImageView *_resolvedImageView;
	
	NSTimer *_timer;
	NSAnimation *_animation;
	NSString *_imagePath;
	NSSound *_buzzerSound;
	float _startingBlockSize;
	BOOL  _paused;
	
	TriviaPlayer *_buzzedPlayer;
}

- (IBAction)pause:(id)sender;
- (IBAction)nextImage:(id)sender;
- (IBAction)rightAnswer:(id)sender;
- (IBAction)wrongAnswer:(id)sender;
- (IBAction)fullscreen:(id)sender;
@end

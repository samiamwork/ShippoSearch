//
//  ShippoSearchDelegate.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import "ShippoSearchDelegate.h"


@implementation ShippoSearchDelegate

- (void)awakeFromNib
{
	_fullscreenController = [[FullscreenSheetController alloc] init];
	[_fullscreenController setAttachedWindow:_gameWindow];
	[_imageView setImage:nil];
	
	[_imageView setPixelSize:1.0f];
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0f target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
	_animation = [[NSAnimation alloc] initWithDuration:15.0 animationCurve:NSAnimationLinear];
	[_animation setAnimationBlockingMode:NSAnimationNonblocking];
	[_playerController setDelegate:self];
	
	_buzzedPlayer = nil;
}

- (void)dealloc
{
	[_timer invalidate];
	[_animation release];
	[_imagePath release];
	[_fullscreenController release];

	[super dealloc];
}

- (void)animationTick:(NSTimer *)theTimer
{
	if( ![_animation isAnimating] )
		return;
	
	[_imageView setPixelSize:[_animation currentValue]*49.0f+1.0f];
}

- (IBAction)nextImage:(id)sender
{
	[_imageController removeImage:_imagePath];
	_imagePath = [[_imageController getImage] retain];
	
	NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:_imagePath];
	CIImage *newImage =  [[CIImage alloc] initWithContentsOfURL:imageURL];
	[_imageView setImage:newImage];
	[imageURL release];
	[newImage release];
	[_imageView setPixelSize:50.0f];
	
	[_animation setCurrentProgress:0.0];
	[_animation startAnimation];
	[_playerController setAllPlayersEnabled:YES];
}

- (void)playerBuzzed:(TriviaPlayer *)thePlayer
{
	_buzzedPlayer = thePlayer;
	[_buzzedPlayerName setStringValue:[thePlayer name]];
	[_animation stopAnimation];
	
}

- (IBAction)rightAnswer:(id)sender
{
	if( !_buzzedPlayer )
		return;
	
	[_buzzedPlayer addPoints:(int)([_animation currentValue]*30.0f)];
	[_imageView setPixelSize:1.0f];
	[_animation setCurrentProgress:0.0];
	[_playerController setAllPlayersEnabled:NO];
	[_playerController reloadData];
	[_buzzedPlayerName setStringValue:@""];
	_buzzedPlayer = nil;
}
- (IBAction)wrongAnswer:(id)sender
{
	if( !_buzzedPlayer )
		return;
	
	[_buzzedPlayer subtractPoints:(int)([_animation currentValue]*30.0f)];
	[_buzzedPlayer setEnabled:NO];
	[_animation startAnimation];
	[_playerController reloadData];
	[_buzzedPlayerName setStringValue:@""];
	_buzzedPlayer = nil;
}

- (IBAction)fullscreen:(id)sender
{
	[_fullscreenController toggleFullscreen];
}
@end

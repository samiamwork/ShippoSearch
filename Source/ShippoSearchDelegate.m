//
//  ShippoSearchDelegate.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import "ShippoSearchDelegate.h"


@implementation ShippoSearchDelegate

+ (void)initialize
{
	NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:18],@"imageDisplaySeconds",
							  [NSNumber numberWithInt:50],@"startingBlockSize",
							  [NSNumber numberWithInt:0],@"minimumValue",
							  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)awakeFromNib
{
	[_imageView setImage:nil];	
	[_imageView setPixelSize:1.0f];
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0f target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
	_animation = [[NSAnimation alloc] initWithDuration:(NSTimeInterval)[[NSUserDefaults standardUserDefaults] integerForKey:@"imageDisplaySeconds"] animationCurve:NSAnimationLinear];
	[_animation setAnimationBlockingMode:NSAnimationNonblocking];
	[_playerController setDelegate:self];
	
	_buzzedPlayer = nil;
	_paused = NO;
	
	_buzzerSound = [[NSSound soundNamed:@"Submarine"] retain];
}

- (void)dealloc
{
	[_timer invalidate];
	[_animation release];
	[_imagePath release];
	[_buzzerSound release];

	[super dealloc];
}

- (int)scoreForValue:(float)theValue
{
	float score = (1.0f-theValue)*10.0f;
	score *= score;
	NSInteger minimumValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"minimumValue"];
	if(score < minimumValue)
	{
		score = minimumValue;
	}
	return (int)score;
}

- (void)animationTick:(NSTimer *)theTimer
{
	if( ![_animation isAnimating] )
		return;
	
	[_imageView setPixelSize:(1.0f-sqrtf([_animation currentProgress]))*(_startingBlockSize-1.0f)+1.0f];
	[_pointValueField setIntValue:[self scoreForValue:[_animation currentProgress]]];
}

- (IBAction)pause:(id)sender
{
	if(!_paused && [_animation isAnimating])
	{
		_paused = YES;
		[_animation stopAnimation];
	}
	else if(_paused)
	{
		_paused = NO;
		if([_animation currentProgress] < 1.0)
		{
			[_animation startAnimation];
		}
	}
}

- (IBAction)nextImage:(id)sender
{
	_paused = NO;
	[_imageController removeImage:_imagePath];
	_imagePath = [[_imageController getImage] retain];
	
	NSURL *imageURL = [[NSURL alloc] initFileURLWithPath:_imagePath];
	CIImage *newImage =  [[CIImage alloc] initWithContentsOfURL:imageURL];
	[_imageView setImage:newImage];
	[imageURL release];
	[newImage release];
	_startingBlockSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"startingBlockSize"];
	[_imageView setPixelSize:_startingBlockSize];
	
	_buzzedPlayer = nil;
	[_animation setDuration:(NSTimeInterval)[[NSUserDefaults standardUserDefaults] integerForKey:@"imageDisplaySeconds"]];
	[_animation setCurrentProgress:0.0];
	[_animation startAnimation];
	[_playerController setAllPlayersEnabled:YES];
}

- (void)playerBuzzed:(TriviaPlayer *)thePlayer
{
	if( _buzzedPlayer || _paused)
		return;
	
	_buzzedPlayer = thePlayer;
	[_buzzedPlayerName setStringValue:[thePlayer name]];
	[_animation stopAnimation];
	[_buzzerSound play];
}

- (IBAction)rightAnswer:(id)sender
{
	if( !_buzzedPlayer )
		return;
	
	[_buzzedPlayer addPoints:[self scoreForValue:[_animation currentProgress]]];
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
	
	[_buzzedPlayer subtractPoints:[self scoreForValue:[_animation currentProgress]]];
	[_buzzedPlayer setEnabled:NO];
	if([_animation currentProgress] < 1.0)
	{
		[_animation startAnimation];
	}
	[_playerController reloadData];
	[_buzzedPlayerName setStringValue:@""];
	_buzzedPlayer = nil;
}

- (IBAction)fullscreen:(id)sender
{
	[_gameWindow toggleFullscreen:self];
}
@end

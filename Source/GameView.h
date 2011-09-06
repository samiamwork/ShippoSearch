//
//  GameView.h
//  ShippoSearch
//
//  Created by Nur Monson on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class GameView;
@protocol GameViewDelegate
- (void)gameViewImageShown:(GameView*)gameView;
@end

@interface GameView : NSView
{
	CALayer* _rootLayer;
	CALayer* _imageLayer;
	CALayer* _playerLayer;
	CGFloat  _pixelSize;

	CABasicAnimation* _slideIn;
	CABasicAnimation* _slideOut;
	NSArray*          _players;
}

@property (assign,readwrite) NSObject<GameViewDelegate>* delegate;
@property (retain,readwrite) NSArray* players;

- (void)setImage:(NSImage *)theImage;
- (void)setPixelSize:(CGFloat)pixelSize;
- (void)showPlayers;
@end

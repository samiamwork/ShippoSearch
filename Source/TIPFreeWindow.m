#import "TIPFreeWindow.h"

@implementation TIPFreeWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	if( (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:deferCreation]) ) {
		_fullscreenController = [[FullscreenSheetController alloc] init];
		[_fullscreenController setAttachedWindow:self];
	}

	return self;
}

- (void)dealloc
{
	[_fullscreenController release];

	[super dealloc];
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)aScreen
{
	return frameRect;
}

- (IBAction)toggleFullscreen:(id)sender
{
	[_fullscreenController toggleFullscreen];
}

@end

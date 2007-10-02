/* TIPFreeWindow */

#import <Cocoa/Cocoa.h>
#import "FullscreenSheetController.h"

@interface TIPFreeWindow : NSWindow
{
	FullscreenSheetController *_fullscreenController;
}

- (IBAction)toggleFullscreen:(id)sender;
@end

//
//  CIView.m
//  ShippoSearch
//
//  Created by Nur Monson on 9/27/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "CIView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>


@implementation CIView

+ (NSOpenGLPixelFormat *)defaultPixelFormat
{
	static NSOpenGLPixelFormat *pf = nil;
	
	if( !pf ) {
		static const NSOpenGLPixelFormatAttribute attr[] = {
			NSOpenGLPFAAccelerated,
			NSOpenGLPFANoRecovery,
			NSOpenGLPFAColorSize, 32,
			0 };
		
		pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:(void *)&attr];
	}
	
	return pf;
}

- (void)dealloc
{
	[_image release];
	[_context release];
	
	[super dealloc];
}

- (CIImage *)image
{
	return _image;
}

- (void)setImage:(CIImage *)theImage dirtyRect:(CGRect)theRect;
{
	if( theImage == _image )
		return;
	
	[_image release];
	_image = [theImage retain];
	
	if( CGRectIsInfinite(theRect) )
		[self setNeedsDisplay:YES];
	else
		[self setNeedsDisplayInRect:*(NSRect *)&theRect];
}

- (void)setImage:(CIImage *)theImage
{
	[self setImage:theImage dirtyRect:CGRectInfinite];
}

- (void)prepareOpenGL
{
	long param = 1;
	[[self openGLContext] setValues:&param forParameter:NSOpenGLCPSwapInterval];
	
	glDisable( GL_ALPHA_TEST );
	glDisable( GL_DEPTH_TEST );
	glDisable( GL_SCISSOR_TEST );
	glDisable( GL_BLEND );
	glDisable( GL_DITHER );
	glDisable( GL_CULL_FACE );
	
	glColorMask( GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE );
	glDepthMask( GL_FALSE );
	glStencilMask( 0 );
	glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
	glHint( GL_TRANSFORM_HINT_APPLE, GL_FASTEST );

}

- (void)viewBoundsDidChange:(NSRect)bounds
{
	// for subclass
}

- (void)updateMatrices
{
	NSRect bounds = [self bounds];
	
	if( NSEqualRects( bounds, _lastBounds ) )
		return;
	
	[[self openGLContext] update];
	
	glViewport(0,0, bounds.size.width,bounds.size.height);
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrtho( 0.0, bounds.size.width, 0.0, bounds.size.height, -1.0, 1.0);
	
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	_lastBounds = bounds;
	[self viewBoundsDidChange:bounds];
}

- (void)drawRect:(NSRect )theRect
{
	[[self openGLContext] makeCurrentContext];
	
	if( !_context ) {
		NSOpenGLPixelFormat *pf = [self pixelFormat];
		if( !pf )
			pf = [[self class] defaultPixelFormat];
		
		_context = [[CIContext contextWithCGLContext:CGLGetCurrentContext() pixelFormat:[pf CGLPixelFormatObj] options:nil] retain];
	}
	
	[self updateMatrices];
	CGRect integralRect = CGRectIntegral( *(CGRect *)&theRect );
	CGRect rRect = CGRectIntersection( CGRectInset(integralRect,-1.0f,-1.0f),*(CGRect *)&_lastBounds);
	
	glScissor( integralRect.origin.x,integralRect.origin.y,integralRect.size.width,integralRect.size.height );
	glEnable( GL_SCISSOR_TEST );
	glClear( GL_COLOR_BUFFER_BIT );
	
	if( [self respondsToSelector:@selector(drawRect:inCIContext:)] )
		[self drawRect:*(NSRect *)&rRect inCIContext:_context];
	else if( _image ) {
		CGPoint imageLoc;
		CGSize imageSize = [_image extent].size;
		imageLoc.x = floorf((_lastBounds.size.width - imageSize.width)/2.0f);
		imageLoc.y = floorf((_lastBounds.size.height - imageSize.height)/2.0f);
		[_context drawImage:_image atPoint:imageLoc fromRect:rRect];
	}
	
	glDisable( GL_SCISSOR_TEST );
	glFlush();
}
@end

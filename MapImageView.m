//
//  MapView.m
//  agemap1
//
//  Created by Peter Appel on 24/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapImageView.h"

@implementation MapImageView

- (void)drawRect:(NSRect)rect 
{
  [super drawRect:rect];
}

- (void)broadcast
{
    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify postNotificationName:@"transformChanged" object:nil];
}

	// NSResponder methods.  
-(void)mouseDown:(NSEvent *)event
{
    [self mouseDragged:event];
}


// there is a much better method also dealing with colors in "Color Sampler" sample code
-(void)mouseDragged:(NSEvent *)event
{


//    NSPoint p = [event locationInWindow];
//    lastPoint = [self convertPoint:p fromView:self];
	NSPoint pos = [self convertPoint:[event locationInWindow] fromView:nil];

    if (!([event modifierFlags] & NSControlKeyMask))
    {
//		NSLog(@"mouseDragged: %@", event);
        [self setPosition:pos];
        [self broadcast];
        [self setNeedsDisplay:YES];
    }
	/* from color sampler

	NSPoint pos = [self convertPoint:[event locationInWindow] fromView:nil];
	
	
	
	[self lockFocus];
	int pixelValue = NSReadPixel(pos);
	[self unlockFocus];
	[reportText setStringValue:[NSString stringWithFormat:@"At: (%.0f,%.0f) V = %.2f", pos.x, pos.y, pixelValue]];
*/
}



- (void) mouseUp:(NSEvent *) theEvent 
{ 
//	NSLog(@"mouseUp:");
}

- (NSPoint)position
{
    return position;
}

- (void)setPosition:(NSPoint)value;
{
    position = value;
}



@end

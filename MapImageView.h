//
//  MapView.h
//  agemap1
//
//  Created by Peter Appel on 24/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSByteOrder.h>

@interface MapImageView : NSImageView {

//IBOutlet id reportText;

NSImage *image;
NSPoint lastPoint;
NSPoint position;
}

// -(void)setPixelValue:(int)newValue;
-(void)broadcast;
-(void)drawRect:(NSRect)rect;

- (NSPoint)position;
- (void)setPosition:(NSPoint)value;

@end


//
//  HistoView.m
//  MacAgeMap
//
//  Created by Peter Appel on 15/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoView.h"


@implementation HistoView


- (id)initWithFrame:(NSRect)frameRect
{
//	float axisLength;
//	axisLength = 400.0;
if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
			[self setBoundsOrigin:NSMakePoint(-40.0,-20.0)];
			[self setNeedsDisplay: YES];
			[self prepareAttributes];
	}
	return self;
}

/*
-(void)showData:(NSArray *)intervallCounts
{
id object;
NSEnumerator *enumerator = [intervallCounts objectEnumerator];
while (object = [enumerator nextObject]) {
	NSLog(@"counts %@", object);
	}
[self setNeedsDisplay:YES];
}
*/

- (void)setIntervallCounts:(NSArray *)anIntervallCounts
{
    if (intervallCounts != anIntervallCounts) {
        [intervallCounts release];
        intervallCounts = [anIntervallCounts mutableCopy];
    }
}


- (void)setXMax:(int)x
{
xMax = x;
}



-(int)getMaxCount:(NSArray *)anArray
{
int maxCount = 0;
int index;

for (index=5; index < [anArray count]; index++) {

// this works also
//val = [[anArray objectAtIndex:index] intValue];
//maxCount = (val > maxCount) ? val: maxCount  ;

	if ([[anArray objectAtIndex:index] intValue] > maxCount) {
		maxCount = [[anArray objectAtIndex:index] intValue]; 
		}
	}
return maxCount;
}



-(void)drawRect:(NSRect)rect
{
	NSPoint a, b, c;
	float xStep, yStep;

	NSRect bounds = [self bounds];
	float tickLength;	
	float xAxisLength;
	float yAxisLength;
	tickLength = 3;
	xAxisLength = 450.0;	
	yAxisLength = 160.0;
	[[NSColor whiteColor] set];
	
	[NSBezierPath fillRect:bounds];
	
	[[NSColor blackColor] set];
	NSEraseRect(rect);
	NSLog(@"histoView  %@", self);

// Draw x-y axis
	NSBezierPath *path;
	path = [[NSBezierPath alloc] init];
			[path setLineWidth: 1.0];
			a.x = 0.0;
			a.y = 0.0;
			b.x = a.x + xAxisLength;
			b.y = a.y;
			c.x = a.x;
			c.y = a.y + yAxisLength;
			[path moveToPoint: c];
			[path lineToPoint: a];
			[path lineToPoint: b];
	//		[path closePath];
	[path stroke];
// Draw axis ticks
	
int y, mc, index, yMax;
mc = [self getMaxCount:intervallCounts];

NSBezierPath *histoPath = [[NSBezierPath alloc] init];
xStep = xAxisLength/(xMax-100);
yStep = yAxisLength/mc;

[histoPath moveToPoint: a];
yMax = 0;
for (index=5; index < [intervallCounts count]; index++) {
		y = [[intervallCounts objectAtIndex:index] intValue];
//		NSLog(@"counts at index  %i  %i", y, index );
		b.x = xStep * (index-5) * 20;
		b.y = yStep * y;
		[histoPath lineToPoint:b];
		if ([[intervallCounts objectAtIndex:index] intValue] > yMax) {
			yMax = [[intervallCounts objectAtIndex:index] intValue];
			}
		}
	[histoPath stroke];


int numberOfXTicks = rint(xMax/500);
int xLabel;
NSString *stringXLabel;
NSBezierPath *tickPath = [[NSBezierPath alloc] init]; 
for (index = 1; index < (numberOfXTicks+1); index++) {
xLabel = 500 * index;
stringXLabel = [NSString stringWithFormat:@"%i", xLabel];
b.x = xStep * (xLabel - 100.0);
[stringXLabel drawAtPoint:NSMakePoint(b.x - [stringXLabel sizeWithAttributes:attributes].width/2, -15.0) withAttributes:attributes]; 	

[tickPath moveToPoint:NSMakePoint( b.x, 0.0)];
[tickPath lineToPoint:NSMakePoint( b.x, tickLength)];
[tickPath stroke];
}




//	NSLog(@"ymax %i", yMax);

int numberOfYTicks = rint(yMax/200);
int yLabel;
NSString *stringYLabel;
//NSBezierPath *tickPath = [[NSBezierPath alloc] init]; 
for (index = 1; index < (numberOfYTicks+1); index++) {
yLabel = 200 * index;
stringYLabel = [NSString stringWithFormat:@"%i", yLabel];
b.y = yStep * yLabel;
[stringYLabel drawAtPoint:NSMakePoint(-5.0 - [stringYLabel sizeWithAttributes:attributes].width, b.y - [stringYLabel sizeWithAttributes:attributes].height/2) withAttributes:attributes]; 	

[tickPath moveToPoint:NSMakePoint(0.0, b.y)];
[tickPath lineToPoint:NSMakePoint(tickLength, b.y)];
[tickPath stroke];
}


//	Draw ticks


//	[super drawRect:rect];
	
	[self retain];
	
}

- (void)prepareAttributes
{
    attributes = [[NSMutableDictionary alloc] init];
    
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:11]
                   forKey:NSFontAttributeName];
    
    [attributes setObject:[NSColor blackColor]
                   forKey:NSForegroundColorAttributeName];
}


//
// The action for saving to PDF file. Just do a save panel and
// use -didEnd to handle results.
//
-(IBAction)saveToPDF:(id)sender
{
	NSSavePanel * panel = [NSSavePanel savePanel];
	NSLog(@"savePDF",self);
	[panel setRequiredFileType: @"pdf"];
	[panel beginSheetForDirectory: nil
							 file: nil
				   modalForWindow: [self window]
					modalDelegate: self
				   didEndSelector: @selector(didEnd:returnCode:contextInfo:)
					  contextInfo: nil];
}


//
// Do this after the PDF file target has been set.
//
-(void) didEnd: (NSSavePanel *)sheet returnCode:(int)code 
   contextInfo: (void *)contextInfo
{
	if(code == NSOKButton)
	{
		NSLog(@"didEnd called for %@", self);
		NSRect r = [self bounds];
		NSData *data = [self dataWithPDFInsideRect: r];
		[data writeToFile: [sheet filename] atomically: YES];
	}
}


@end

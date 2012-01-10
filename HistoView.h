//
//  HistoView.h
//  MacAgeMap
//
//  Created by Peter Appel on 15/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface HistoView : NSView {
//	IBOutlet NSWindow *window;
	NSMutableDictionary *attributes;
	NSArray *intervallCounts;
	int xMax;
	IBOutlet NSButton *SaveButton;
}



//- (NSArray *)intervallCounts;

- (void)setIntervallCounts:(NSArray *)anIntervallCounts;
- (void)setXMax:(int)x;
//- (void)setYMax:(int)y;

//-(void)showData:(NSArray *)intervallCounts;
-(void)prepareAttributes;
-(int)getMaxCount:(NSArray *)intervallCounts;
-(IBAction)saveToPDF:(id)sender;

@end

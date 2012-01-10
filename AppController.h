/* MapViewer */

#import <Cocoa/Cocoa.h>
@class MapImageView;
@class HistoView;

@interface AppController : NSObject
{

float probeCurrent, th_aVal, u_aVal, pb_aVal, th_bVal, u_bVal, pb_bVal, th_ZAF, u_ZAF, pb_ZAF, magnification, o_fac;

int width, height, dwell, max_age, min_age, curTag, max_intervallCounts, ageThreshold;
NSMutableDictionary *attributes;
NSMenu *menu;

IBOutlet NSFormCell *textFieldWidth;
IBOutlet NSFormCell *textFieldHeight;

IBOutlet NSTextField *textFieldPC;
IBOutlet NSTextField *textFieldDwell;

IBOutlet NSTextField *textFieldThA;
IBOutlet NSTextField *textFieldThB;
IBOutlet NSTextField *textFieldThZAF;

IBOutlet NSTextField *textFieldUA;
IBOutlet NSTextField *textFieldUB;
IBOutlet NSTextField *textFieldUZAF;

IBOutlet NSTextField *textFieldPbA;
IBOutlet NSTextField *textFieldPbB;
IBOutlet NSTextField *textFieldPbZAF;

IBOutlet NSTextField *textFieldOvlFac;

IBOutlet NSTextField *textFieldAgeThreshold;


IBOutlet NSWindow *window;
IBOutlet NSWindow *mapViewWindow;

IBOutlet NSButton *loadRawThMapButton;
IBOutlet NSButton *loadRawUMapButton;
IBOutlet NSButton *loadRawPbMapButton;


IBOutlet NSButton *calculateButton;

IBOutlet NSButton *updateImageButton;

// NSImage *tmpImage;

IBOutlet MapImageView *thRawView;
IBOutlet MapImageView *uRawView;
IBOutlet MapImageView *pbRawView;

IBOutlet MapImageView *thStarView;
IBOutlet MapImageView *ageView;

IBOutlet MapImageView *largeImageView;

IBOutlet HistoView *histoView;

IBOutlet id reportText;

id curItem;

NSImage *ageImage;
NSImage *thImage;
NSImage *uImage;
NSImage *pbImage;
NSImage *thStarImage;
NSImage *levelImage;
NSImage *aLargeImage;

NSData *thRawMapData;
NSData *uRawMapData; 
NSData *pbRawMapData;

NSMutableData *rawMapData;

NSData *uLineCorrMapData;


NSData *thConcMapData;
NSData *uConcMapData;
NSData *pbConcMapData;

NSMutableData *ageMapData;

NSData *thStarMapData;

//NSBitmapImageRep *destImageRep;

// BOOL enableCalcButton;


}
- (IBAction)saveAgeImage:(id)sender;
- (IBAction)saveDataFile:(id)sender;

/*
-(IBAction)showLargeAgeMapWindow:(id)sender;
-(IBAction)showLargeThMapWindow:(id)sender;
-(IBAction)showLargeUMapWindow:(id)sender;
-(IBAction)showLargePbMapWindow:(id)sender;
-(IBAction)showLargeThStarMapWindow:(id)sender;
*/

-(IBAction)showLargeMapWindow:(id)sender;

-(IBAction)updateAgeImage:(id)sender;

-(void)setPixelInfoField;
-(void)prepareAttributes;


-(NSImage *)createLevelImage;

-(void)buildHistogramData:(NSMutableData *)data;


// ****** general conditions *******
-(int)width;

-(void)setWidth:(int)x;

-(int)dwell;

-(void)setDwell:(int)x;

-(int)height;

-(void)setHeight:(int)x;

-(float)probeCurrent;

-(void)setProbeCurrent:(float)x;

-(int)ageThreshold;

-(void)setAgeThreshold:(int)x;


// ****** a-Values *******
-(float)th_aVal;

-(void)setTh_aVal:(float)x;

-(float)u_aVal;

-(void)setU_aVal:(float)x;

-(float)pb_aVal;

-(void)setPb_aVal:(float)x;

// ****** b-Values *******
-(float)th_bVal;

-(void)setTh_bVal:(float)x;

-(float)u_bVal;

-(void)setU_bVal:(float)x;

-(float)pb_bVal;

-(void)setPb_bVal:(float)x;

// ****** ZAF *******
-(float)th_ZAF;

-(void)setTh_ZAF:(float)x;

-(float)u_ZAF;

-(void)setU_ZAF:(float)x;

-(float)pb_ZAF;

-(void)setPb_ZAF:(float)x;

-(float)o_fac;

-(void)setO_fac:(float)x;

- (IBAction)loadRawMapFile:(id)sender;
-(IBAction)calculateAgeMap:(id)sender;

-(NSData *)buildConcMapDataFrom:(NSData *)data aVal:(float)a_val bVal:(float)b_val zafVal:(float)zaf_val;
-(NSMutableData *)buildAgeMapFromThMap:thData UMap:uData PbMap:pbData;

-(NSData *)buildOverlapCorrectionUMap;

-(NSImage *)createAgeImage:(NSData *)data;

-(NSImage *)buildImageFromDataStream:(NSString *)path;

@end

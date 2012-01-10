#import "AppController.h"
#import "COMP2AGE.h"
#import "MapImageView.h"
#import "HistoView.h"

@implementation AppController


-(void)awakeFromNib
{

    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(handleNotify:)
                   name:@"transformChanged" object:nil];;
    [self setPixelInfoField];    
	[self prepareAttributes];
	
 [textFieldAgeThreshold setIntValue: 4000];	
 [self setAgeThreshold:[textFieldAgeThreshold intValue]];

 [textFieldWidth setIntValue: 280];
 [textFieldHeight setIntValue: 180];
 [self setWidth:[textFieldWidth intValue]];
 [self setHeight:[textFieldHeight intValue]];

 [textFieldPC setFloatValue: 0.250];
 [textFieldDwell setIntValue: 700];
 
 [textFieldThA setFloatValue: 1.2568];
 [textFieldThB setFloatValue: 0.4599];
 [textFieldThZAF setFloatValue: 1];

 [textFieldUA setFloatValue: 0.7565];
 [textFieldUB setFloatValue: 0.7960];
 [textFieldUZAF setFloatValue: 1];
 
 [textFieldPbA setFloatValue: 1.1112];
 [textFieldPbB setFloatValue: 0.7857];
 [textFieldPbZAF setFloatValue: 1];
 [textFieldOvlFac setFloatValue: 0.0044];
}

- (void)handleNotify:(NSNotification *)n
{
    [self setPixelInfoField];
}

-(void)setPixelInfoField
{
	unsigned short buffer;
    NSPoint p = [largeImageView convertPoint:[largeImageView position] fromView:largeImageView];

//	[reportText setStringValue:[NSString stringWithFormat:@"Value At: (%.0f, %.0f) = %i", NSStringFromPoint([largeImageView position])]];
	NSLog(@"reportText  %f  %f", p.x/magnification, p.y/magnification); 
	int offset = (height - rint(p.y/magnification) -1) * width  + rint(p.x/magnification);
//	[[curItem representedObject] getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * index, sizeof(unsigned short))];

switch (curTag) {
	case 1: {
		[thRawMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * offset, sizeof(unsigned short))];
		break;
		}
	case 2: {
		[pbRawMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * offset, sizeof(unsigned short))];
		break;
		}
	case 3: {
		[uRawMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * offset, sizeof(unsigned short))];
		break;
		}
	case 4: {
		[thStarMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * offset, sizeof(unsigned short))];
		break;
		}
	case 5: {
		[ageMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * offset, sizeof(unsigned short))];
		break;
		}
	default:
		break;
	}
	[reportText setStringValue:[NSString stringWithFormat:@"Value @(%.0f,%.0f) = %i", p.x/magnification, p.y/magnification, buffer]];
  NSLog(@"reportText  %@ ", curItem ); 


}

	
- (IBAction)loadRawMapFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSLog(@"load the raw data file");
    [panel beginSheetForDirectory:nil 
							 file:nil 
							types:nil 
				   modalForWindow:window
					modalDelegate:self 
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
					  contextInfo:(void *)[sender tag]];
    [panel setCanChooseDirectories:NO];
    [panel setPrompt:@"Choose File"];
}


- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void  *)buttonTagNumber
{
    NSString *filePath;
    if (returnCode == NSOKButton) {
        filePath = [openPanel filename];
		
		switch ((int)buttonTagNumber)
		{
			case 1:		// Thorium
			{
				thImage = [self buildImageFromDataStream:filePath];
				thRawMapData = [NSData dataWithData:rawMapData];
				NSLog(@"get Bytes from thMap  %i", [thRawMapData length] ); 
				[thRawView lockFocus];
				[[NSGraphicsContext currentContext] setImageInterpolation: (NSImageInterpolation) NSImageInterpolationNone];
				[thRawView setImage:thImage];
				[thRawView unlockFocus];
				[thRawMapData retain];

				break;
			}	
				
			case 2:		// Uranium
			{
				uImage = [self buildImageFromDataStream:filePath];
				uRawMapData = [NSData dataWithData:rawMapData];
				NSLog(@"get Bytes from UMap  %i", [uRawMapData length] ); 
				[uRawView lockFocus];
				[[NSGraphicsContext currentContext] setImageInterpolation: (NSImageInterpolation) NSImageInterpolationNone];
				[uRawView setImage:uImage];		// This draws the image on the screen
				[uRawView unlockFocus];
				[uRawMapData retain];		// Important - we want to keep the map data 

			break;
			}	
				
			case 3:		// Pb
			{
				pbImage = [self buildImageFromDataStream:filePath];
				pbRawMapData = [NSData dataWithData:rawMapData];
				NSLog(@"get Bytes from PbMap  %i", [pbRawMapData length] ); 
				[pbRawView lockFocus];
				[[NSGraphicsContext currentContext] setImageInterpolation: (NSImageInterpolation) NSImageInterpolationNone];
				[pbRawView setImage:pbImage];
				[pbRawView unlockFocus];
				[pbRawMapData retain];		// Important - we want to keep the map data 

				break;
			}	
				
			default:
				break;		// This should never occur of course,,,
		}		

		if (([thRawMapData length] > 0) && ([uRawMapData length] > 0) && ([pbRawMapData length] > 0))
			[calculateButton setEnabled:YES];
		else
				[calculateButton setEnabled:NO];
	}
}



- (IBAction)saveAgeImage:(id)sender
  {
  [[NSSavePanel savePanel]
    beginSheetForDirectory:NSHomeDirectory()  // seems like a reasonable place to start..
    file:@"AgeImage" 	// default filename
    modalForWindow:window   //Run as a sheet, attached to "window"
    modalDelegate:self 	// The save panel should call me when it's done..
    didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) // ... using this selector
    contextInfo:NULL];
  }

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
  {
  if (returnCode == NSOKButton)  // The user hit "save", so...
    [[aLargeImage TIFFRepresentation]  // Create the contents of a .tiff file
      writeToFile:[[sheet filename] stringByAppendingString: @".tiff"] // save it at the path we get from the panel.
      atomically:YES];  // That's about all there is to it..
  }


- (IBAction)saveDataFile:(id)sender
  {
  [[NSSavePanel savePanel]
    beginSheetForDirectory:NSHomeDirectory()  // seems like a reasonable place to start..
    file:@"RawAgeData" 	// default filename
    modalForWindow:window   //Run as a sheet, attached to "window"
    modalDelegate:self 	// The save panel should call me when it's done..
    didEndSelector:@selector(saveDataDidEnd:returnCode:contextInfo:) // ... using this selector
    contextInfo:NULL];
  }

- (void)saveDataDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
  {
  if (returnCode == NSOKButton)  // The user hit "save", so...
    [ageMapData writeToFile:[[sheet filename] stringByAppendingString: @".data"] // save it at the path we get from the panel.
      atomically:YES];  // That's about all there is to it..
  }


-(NSImage *)buildImageFromDataStream:(NSString *)path
{
unsigned short   buffer, swappedbuf;
int index = 0;
int max;

//const unsigned short imageSizeParam = 100;

// const float ratio =  pow(2, 8*sizeof(unsigned char)) / pow(2, 8*sizeof(unsigned short)); 
// sizeof(unsigned char) is 1 -> 256 bits
// sizeof(unsigned short) is 2 -> 65536 bits

 [self setWidth:[textFieldWidth intValue]];
 [self setHeight:[textFieldHeight intValue]];
 
if (height > width) 
					magnification = (float)[largeImageView bounds].size.height/(float)height;	// magnification needed for largeImageViews
					else 
					magnification = (float)([largeImageView bounds].size.width-150)/(float)width;

NSImage *destImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    
NSBitmapImageRep *destImageRep = [[[NSBitmapImageRep alloc] 
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:width   // Data ordered y with origin upper left corner in Jeol datafile 
                    pixelsHigh:height	//
                    bitsPerSample:8 
                    samplesPerPixel:1
                    hasAlpha:NO
                    isPlanar:NO
                    colorSpaceName:NSCalibratedWhiteColorSpace
                    bytesPerRow:width	//w * bps * spp / 8	(Anguish p 557)
                    bitsPerPixel:8	//For meshed image: bps * spp (p 558)
					] autorelease];

  unsigned char *destData = [destImageRep bitmapData];
  unsigned char *p1;
  NSLog(@"sizeof uc,  %hu, sizeof us %hu", sizeof(unsigned char), sizeof(unsigned short));

 // NSData *tmpMapData = [NSData dataWithContentsOfFile:path];	
  rawMapData = [NSMutableData dataWithContentsOfFile:path];	
  
  // hier könnte man statt rawMapData zunächst ein tmpMapData verwenden, 
  
//  max = ([rawMapData length] / sizeof(unsigned short)) ;
  max = ([rawMapData length] / sizeof(unsigned short)) ;
	int	max_val = 0;
		while (index < max) { 
		
// und hier tmpMapData mit NSSwapHostShortToBig(buffer) zu rawMapData konvertieren
// ev so: NSMutableData *rawMapData = [NSMutableData data]; [rawMapData appendBytes:&buffer length:sizeof(unsigned short)];

			[rawMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * index, sizeof(unsigned short))];
			
			// This is for Intel (little) -Architecture
			swappedbuf = NSSwapHostShortToBig(buffer);
			// Noch zu klären  ist, ob die mit Intel-Proz. erzeugten Files auf der Jeol Workstation gelesen werde
			
			[rawMapData replaceBytesInRange:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short)) withBytes:&swappedbuf length:sizeof(unsigned short)];
			if (swappedbuf > max_val)
				max_val = swappedbuf	;
			}
			
			
		index = 0;
	const float ratio =  pow(2, 8*sizeof(unsigned char)) / max_val; 

			
	// Übertragen der Pixelinformationen vom NSData Objekt in das neue NSBitmapImageRep	über den Pointer destData			
	while (index < max) { 
			[rawMapData getBytes:&buffer range:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short))];
			p1 = destData++;
			*p1 = (unsigned char)rint(buffer * ratio);
//			NSLog(@"concentration %hu, %hu", *p1, counter);
//			NSLog(@"get Bytes from thMap %uc %ui %ui %i", cth, cth, [thRawMapData length], index ); 
			}

[destImage addRepresentation:destImageRep];
//[destImage setSize:NSMakeSize(imageSizeParam, height/width * imageSizeParam)];
[destImage setSize:NSMakeSize(width, height )]; // umgekehrte Anordnung der Daten wegen des internen Aufbaus des Jeol Mapfiles
			// Dort werden die Daten spaltenweise (y) abgelegt, NSBitmapImageRep baut sie aber zeilenweise auf.
			
return [destImage autorelease];			
}


-(IBAction)calculateAgeMap:(id)sender
{
	[self setWidth:[textFieldWidth intValue]];
	[self setHeight:[textFieldHeight intValue]];
	
	[self setProbeCurrent:[textFieldPC floatValue]];
	[self setDwell:[textFieldDwell intValue]];
	
	[self setTh_aVal:[textFieldThA floatValue]];
	[self setTh_bVal:[textFieldThB floatValue]];
	[self setTh_ZAF:[textFieldThZAF floatValue]];
	
	[self setU_aVal:[textFieldUA floatValue]];
	[self setU_bVal:[textFieldUB floatValue]];
	[self setU_ZAF:[textFieldUZAF floatValue]];

	[self setPb_aVal:[textFieldPbA floatValue]];
	[self setPb_bVal:[textFieldPbB floatValue]];
	[self setPb_ZAF:[textFieldPbZAF floatValue]];

	[self setO_fac:[textFieldOvlFac floatValue]];

	[self setAgeThreshold:[textFieldAgeThreshold intValue]];

	// First perform U overlap correction in U data - NSData will be overwritten
//	[self performOverlapCorrectionThOnU];
	
	uLineCorrMapData = [self buildOverlapCorrectionUMap];
		[uLineCorrMapData retain];

	// ...then calculate for each raw map the concentration map, store the data in instances of NSData 
	
	
	thConcMapData = [self buildConcMapDataFrom:thRawMapData aVal:th_aVal bVal:th_bVal zafVal:th_ZAF];
		NSLog(@"1");
	[thConcMapData retain];

	uConcMapData = [self buildConcMapDataFrom:uLineCorrMapData aVal:u_aVal bVal:u_bVal zafVal:u_ZAF];
			NSLog(@"2");
	[uConcMapData retain];


	pbConcMapData = [self buildConcMapDataFrom:pbRawMapData aVal:pb_aVal bVal:pb_bVal zafVal:pb_ZAF];
	[pbConcMapData retain];
		NSLog(@"3");

	// Then use these to calculate an age map, using a C function 
	
	ageMapData = [self buildAgeMapFromThMap:thConcMapData UMap:uConcMapData PbMap:pbConcMapData];
			NSLog(@"4");

	// Display the image
	[self createAgeImage:ageMapData];
			NSLog(@"5");
			
	[self buildHistogramData:ageMapData];		
}


-(NSImage *)createAgeImage:(NSData *)data
{
	int index = 0;
	unsigned short   buff;
    ageImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
//	const float ratio =  pow(2, 8*sizeof(unsigned char)) / max_age; 
	const float ratio =  pow(2, 8*sizeof(unsigned char)) / ageThreshold; 
//	NSLog(@"max_age,  %hi", max_age);
	NSBitmapImageRep *destImageRep = [[[NSBitmapImageRep alloc] 
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:width 
                    pixelsHigh:height
                    bitsPerSample:8 
                    samplesPerPixel:1
                    hasAlpha:NO
                    isPlanar:NO
                    colorSpaceName:NSCalibratedWhiteColorSpace
                    bytesPerRow:width	//w * bps * spp / 8	(Anguish p 557)
                    bitsPerPixel:8	//For meshed image: bps * spp (p 558)
					] autorelease];


		int  max = ([data length] / sizeof(unsigned short)) ;
		unsigned char *destData = [destImageRep bitmapData];
		unsigned char *p1;
		
	// Übertragen der Pixelinformationen vom NSData Objekt in das neue NSBitmapImageRep	über den Pointer destData			
	while (index < max) { 
			[data getBytes:&buff range:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short))];
			p1 = destData++;
			*p1 = (unsigned char)rint(buff * ratio);
	//		NSLog(@"concentration %hu, %hu", *p1, counter);
//			NSLog(@"get Bytes from thMap %uc %ui %ui %i", cth, cth, [thRawMapData length], index ); 
			}

	[ageImage addRepresentation:destImageRep];
	[ageImage setSize:NSMakeSize(width, height)];
	[ageView lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation: (NSImageInterpolation) NSImageInterpolationNone];
	[ageView setImage:ageImage];
	[ageView unlockFocus];
	//		[pbRawMapData retain];		// Important - we want to keep the map data 
	return [ageImage autorelease];
}	

-(NSMutableData *)buildAgeMapFromThMap:thData UMap:uData PbMap:pbData
{
	unsigned short cth, cu, cpb, age_tmp;
	double time;
	int index = 0;
	max_age = 0;
	min_age = 0;
	int max = ([thData length] / sizeof(unsigned short)) ;
	ageMapData = [NSMutableData data];
	[ageMapData retain];
	
	while (index < max) { 
			[thData getBytes:&cth range:NSMakeRange(sizeof(unsigned short) * index, sizeof(unsigned short))];
			[uData getBytes:&cu range:NSMakeRange(sizeof(unsigned short) * index, sizeof(unsigned short))];
			[pbData getBytes:&cpb range:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short))];
			
	//		if ( ((double)(cth)/1000 > 1.0) && ((double)(cth)/1000 < 40.0) && ((double)(cpb)/1000 < 10.0))
						time = ApaAge((double) (cth)/1000, (double) (cu)/1000, (double) (cpb)/1000);
//					else
//						time = 0;

//			if (time < 100)
//				time = 100;
			if (time > 4500)
				time = 4500;
			age_tmp = (unsigned short) time;
			if ((age_tmp > max_age) && (age_tmp != 4500))
				max_age = age_tmp;
			[ageMapData appendBytes:&age_tmp length:sizeof(unsigned short)];
			}
	return ageMapData;
}

-(NSData *)buildConcMapDataFrom:(NSData *)data aVal:(float)a_val bVal:(float)b_val zafVal:(float)zaf_val
{
	unsigned short buff, conc;
	int index = 0;
	float conc_ftmp;
	int max = ([data length] / sizeof(unsigned short)) ;
	NSMutableData *concMapData = [NSMutableData data];

	while (index < max) { 
			[data getBytes:&buff range:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short))];
			conc_ftmp = ((buff/probeCurrent/dwell - b_val) * zaf_val / a_val) * 1000; 
			if (conc_ftmp < 0) { conc_ftmp = 0.0; }
			conc = (unsigned short) conc_ftmp;
//			NSLog(@" %i", conc);

			[concMapData appendBytes:&conc length:sizeof(unsigned short)];
			}

	return [concMapData autorelease];
}

-(NSData *)buildOverlapCorrectionUMap
{
	unsigned short  x_th, x_u;
	unsigned short x_lc;
	float x_flc;
	int index = 0;
	int max = ([uRawMapData length] / sizeof(unsigned short)) ;
	NSMutableData *corMapData = [NSMutableData data];
//	[uLineCorrMapData retain];
	while (index < max) { 
			[thRawMapData getBytes:&x_th range:NSMakeRange(sizeof(unsigned short) * index, sizeof(unsigned short))];
			[uRawMapData getBytes:&x_u range:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short))];
			x_flc = rint(x_u - o_fac * (x_th - th_bVal * probeCurrent)); 
			if (x_flc < 0)
				x_flc = 0;
			x_lc = (unsigned short) x_flc;
//			NSLog(@" %i  %i", x_u, x_lc);
	
			[corMapData appendBytes:&x_lc length:sizeof(unsigned short)];

	
	//		[uRawMapData  replaceBytesInRange:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short)) withBytes:&x_lc];
			}
			return [corMapData autorelease];
}

/*
-(void)buildHistogramData:(NSData *)data
{
//int numberOfClasses;  // this is alos number of indexes
int classCounter[200];
int index;
unsigned short   buff;
int numberOfClasses = 4000 / 50; 
int ck;
int  max = ([data length] / sizeof(unsigned short)) ;
//NSMutableArray *histogramArray;
//[histogramArray initWithCapacity:numberOfClasses];
for (index = 0; index < numberOfClasses; index++) { 
	classCounter[index]=0;
	}
	
index = 0;
	while (index < max) { 
			[data getBytes:&buff range:NSMakeRange(sizeof(unsigned short) * index++, sizeof(unsigned short))];
			ck = (buff / 50);
			classCounter[ck]++; 
			NSLog(@" %i  %i  %i", buff, ck, classCounter[ck]);
			}

		for (index = 0; index < numberOfClasses; index++)	{
			NSLog(@"classCounter %u  %u", index, classCounter[index]);
			}
}
*/


-(void)buildHistogramData:(NSMutableData *)data
{
	// use a C array of integer for basic calculations
	int classCounter[400];			// must be larger than  max. age/widthOfIntervalls
	int index;
	int widthOfIntervalls = 20;													// 20 Ma
	unsigned short   buff;
	int numberOfIntervalls = ageThreshold/widthOfIntervalls;							
	int  max = ([data length]/sizeof(unsigned short)) ;
	NSLog(@" max %i  ", max);

	for (index = 0; index < numberOfIntervalls; index++) { 
		classCounter[index]=0;
	}
	

for (index = 0; index < max; index++) { 
	[data getBytes:&buff range:NSMakeRange(sizeof(unsigned short) * index, sizeof(unsigned short))];
	classCounter[buff/widthOfIntervalls]++; 
	if (classCounter[buff/widthOfIntervalls] > max_intervallCounts) {
		max_intervallCounts = classCounter[buff/widthOfIntervalls]; 
		}
	NSLog(@" %i  %i", buff, classCounter[buff/widthOfIntervalls]);
}

// create an NSArray which contains the counts per intervall as data source for histogram
NSMutableArray *histogramArray = [[NSMutableArray alloc] init];

for (index = 0; index < numberOfIntervalls; index++) { 
	[histogramArray addObject:[NSNumber numberWithInt:classCounter[index]]];
	NSLog(@"object at index %@", [histogramArray objectAtIndex:index]);
	}
[histoView setIntervallCounts:histogramArray];
[histogramArray release];
//[histoView setXMax:max_age];
[histoView setXMax:ageThreshold];
[histoView setNeedsDisplay:YES];
}	




-(IBAction)showLargeMapWindow:(id)sender
{
	int i, ageSteps, scaleSteps;
	float pos;
	NSPoint point;

    aLargeImage = [[NSImage alloc] initWithSize:NSMakeSize([largeImageView bounds].size.width, [largeImageView bounds].size.height)];
	[mapViewWindow makeKeyAndOrderFront:self];				// Shows the window
	NSImage *theImage;
	switch ([sender tag])
	{
	case 1:	// Th map
		{
		theImage  = [[thImage copy] autorelease];
		break;
		}

	case 2:	// U map
		{
		theImage  = [[uImage copy] autorelease];
		break;
		}

	case 3:	// Lead map
		{
		theImage  = [[pbImage copy] autorelease];
		break;
		}

	case 4:
		{
		theImage  = [[thStarImage copy] autorelease];
		break;
		}

	case 5:  // age map
		{
		theImage  = [[ageImage copy] autorelease];
		break;
		}
		
	default:		// should never occur  ;-)
		break;
	}


// draw map image large
	[aLargeImage lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation: (NSImageInterpolation) NSImageInterpolationHigh];		
	[theImage drawInRect:NSMakeRect(0, 0, width * magnification, height * magnification) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
//	[[self createLevelImage] drawInRect:NSMakeRect(555, 0,40, height * magnification) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];


if ([sender tag] == 5)	// special handling for age map: show also level bar with labels
	{
			[[self createLevelImage] drawInRect:NSMakeRect(555, 0,40, height * magnification) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];

			//	NSString *aString;
			//	[aString initWithFormat:@"%i", ageLabelText];
	
//			ageSteps = rint((max_age - min_age)/4);
			ageSteps = rint((ageThreshold - min_age)/4);
			scaleSteps = rint(256/4);
			for (i = 0; i < 5; i++) {
				pos = i *( (height * magnification)/4 );
				NSAttributedString *aString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", ageSteps * i] attributes:attributes];
				if (i < 1) 
					point = NSMakePoint(600, pos);
				else 
					point = NSMakePoint(600, pos -[aString size].height/2);
				[aString drawAtPoint:point];
				}
		NSAttributedString *headerString = [[NSAttributedString alloc] initWithString:@"Ap. Age [Ma]" attributes:attributes];
		[headerString drawAtPoint:NSMakePoint(555, (height * magnification + 20))];
	}


	[aLargeImage unlockFocus];
	[largeImageView setImage:aLargeImage];		// this draws it
	
// & toggle state of windowsMenu items
	[[[NSApp windowsMenu] itemWithTag:(int)curTag] setState:NSOffState];
	[sender setState:NSOnState];
	curTag = [sender tag];
}


-(IBAction)updateAgeImage:(id)sender;
{
[self setAgeThreshold: [textFieldAgeThreshold intValue]];
	// Display the image
	[self createAgeImage:ageMapData];
			
	[self buildHistogramData:ageMapData];		

}






-(NSImage *)createLevelImage
{
	int x, y;
	unsigned short   buff = 255;
    levelImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
	NSLog(@"max_age,  %hi", max_age);
	NSBitmapImageRep *destImageRep = [[[NSBitmapImageRep alloc] 
                    initWithBitmapDataPlanes:NULL
                    pixelsWide:20 
                    pixelsHigh:256
                    bitsPerSample:8 
                    samplesPerPixel:1
                    hasAlpha:NO
                    isPlanar:NO
                    colorSpaceName:NSCalibratedWhiteColorSpace
                    bytesPerRow:20	//w * bps * spp / 8	(Anguish p 557)
                    bitsPerPixel:8	//For meshed image: bps * spp (p 558)
					] autorelease];
		unsigned char *destData = [destImageRep bitmapData];
		unsigned char *p1;
		
		for ( y = 0; y < 256; y++ ) {			
			for ( x = 0; x < 20; x++ ) {
				// Do the magic

				p1 = destData + y * 20 + x;			// Move through the pixels by incrementing a pointer to their memory location
				*p1 = (unsigned char)rint(buff);	// and assign the value of buffer to it		
			}
			buff--;
		}
	[levelImage addRepresentation:destImageRep];
	return [levelImage autorelease];
}	


-(void)createLevelLabels
{	int i, ageSteps, scaleSteps;
	ageSteps = rint((100 - 2900)/4);
	scaleSteps = rint(256/4);
	for (i = 0; i < 5; i++) {
		float	pos =i *( (height * magnification)/4 );
		int	ageLabelText = ageSteps *i;
		NSAttributedString *aString;
		aString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", ageLabelText] attributes:NULL];
		[aString drawAtPoint:NSMakePoint(600,pos)];
	}
}

- (void)prepareAttributes
{
	attributes = [[NSMutableDictionary alloc] init];
	
	[attributes setObject:[NSFont fontWithName:@"Helvetica" size:18]
				   forKey:NSFontAttributeName];
	
	[attributes setObject:[NSColor blackColor]
				   forKey:NSForegroundColorAttributeName];
}


// ****** general conditions *******
-(int)width
{
	return width;
}

-(void)setWidth:(int)x
{
	width = x;
}

-(int)height
{
	return height;
}

-(void)setHeight:(int)x
{
	height = x;
}

-(int)dwell
{
	return dwell;
}

-(void)setDwell:(int)x
{
	dwell = x;
}

-(float)probeCurrent
{
	return probeCurrent;
}

-(void)setProbeCurrent:(float)x
{
	probeCurrent = x;
}

-(int)ageThreshold
{
	return ageThreshold;
}

-(void)setAgeThreshold:(int)x
{
	ageThreshold = x;
}


// ****** a-Values *******
-(float)th_aVal
{
	return th_aVal;
}

-(void)setTh_aVal:(float)x
{
	th_aVal = x;
}

-(float)u_aVal
{
	return u_aVal;
}

-(void)setU_aVal:(float)x
{
	u_aVal = x;
}

-(float)pb_aVal
{
	return pb_aVal;
}

-(void)setPb_aVal:(float)x
{
	pb_aVal = x;
}

// ****** b-Values *******
-(float)th_bVal
{
	return th_bVal;
}

-(void)setTh_bVal:(float)x
{
	th_bVal = x;
}

-(float)u_bVal
{
	return u_bVal;
}

-(void)setU_bVal:(float)x
{
	u_bVal = x;
}

-(float)pb_bVal
{
	return pb_bVal;
}

-(void)setPb_bVal:(float)x
{
	pb_bVal = x;
}

// ****** ZAF *******
-(float)th_ZAF
{
	return th_ZAF;
}

-(void)setTh_ZAF:(float)x
{
	th_ZAF = x;
}

-(float)u_ZAF
{
	return u_ZAF;
}

-(void)setU_ZAF:(float)x
{
	u_ZAF = x;
}

-(float)pb_ZAF
{
	return pb_ZAF;
}

-(void)setPb_ZAF:(float)x
{
	pb_ZAF = x;
}



// Overlap factor used for correcting Th Mgamma on U Mbeta
-(float)o_fac
{
	return o_fac;
}

-(void)setO_fac:(float)x
{
	o_fac = x;
}


-(void)dealloc 
{
	[rawMapData release];
	[thRawMapData release];
	[pbRawMapData release];
	[uRawMapData release];
	
	[uLineCorrMapData release];
	
	[thConcMapData release];
	[uConcMapData release];
	[pbConcMapData release];

	[thStarMapData release];
	[ageMapData release];
	
	NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify removeObserver:self];
	
	[super dealloc];
}

@end

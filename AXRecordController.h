//
//  AXRecordController.h
//  AXRecord
//
//  Created by Christian Frisson on 05/02/17.
//  Copyright © 2017 Christian Frisson and Sylvain Malacria. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowTracker.h"

@interface AXRecordController : NSObject <WindowTrackerDelegate>

-(id)initWithFilename:(NSString *)filename andElementTrackDelay:(float)elementTrackDelay andWindowTrackDelay:(float)windowTrackDelay;
-(id)stop;

@end

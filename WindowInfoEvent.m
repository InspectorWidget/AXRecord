//
//  WindowInfoEvent.m
//  TrackingFramework
//
//  Created by Sylvain Malacria on 10/07/15.
//  Copyright (c) 2015 Sylvain Malacria. All rights reserved.
//

#import "WindowInfoEvent.h"


@implementation WindowInfoEvent

-(id)initWith:(VnrWindowInfo*)windowInfo
atLayerNumber:(int)layernum
 forEventType:(vnrWindowInfoEventType)event
  atTimestamp:(NSTimeInterval)time
      atClock:(uint64)clock
andAllWindows:(NSArray*)allWindows
{
    self = [super init];
    if(self){
        self.windowInfo = windowInfo;
        self.layerNumber=layernum;
        self.eventType = event;
        self.timestamp = time;
        self.clock = clock;
        self.windows = allWindows;
    }
    return self;
}





@end

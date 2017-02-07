//
//  DisplaysInfoEvent.m
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright © 2016 Christian Frisson. All rights reserved.
//

#import "DisplaysInfoEvent.h"

@implementation DisplaysInfoEvent

-(id)initWith:(DisplayInfo*)displaysInfo
//atLayerNumber:(int)layernum
 forEventType:(displaysInfoEventType)event
  atTimestamp:(NSTimeInterval)time
      atClock:(uint64)clock
andAllDisplays:(NSArray*)allDisplays
{
    self = [super init];
    if(self){
        self.displaysInfo = displaysInfo;
        //self.layerNumber=layernum;
        self.eventType = event;
        self.timestamp = time;
        self.clock = clock;
        self.displays = allDisplays;
    }
    return self;
}

@end

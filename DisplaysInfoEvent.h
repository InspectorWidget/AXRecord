//
//  DisplaysInfoEvent.h
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright © 2016 Christian Frisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayInfo.h"

typedef int displaysInfoEventType;
enum {
    displayAppeared,
    displayDisappeared,
    displayMoved,
    displayResized,
    displayReordered,
    displayInit,
    displayUnknown
};
@interface DisplaysInfoEvent : NSObject

@property DisplayInfo* displaysInfo;

//@property int layerNumber;
@property NSTimeInterval timestamp;
@property uint64 clock;

@property displaysInfoEventType eventType;
@property NSArray* displays;

-(id)initWith:(DisplayInfo*)displayInfo
//atLayerNumber:(int)layernum
 forEventType:(displaysInfoEventType)event
  atTimestamp:(NSTimeInterval)time
      atClock:(uint64)clock
andAllDisplays:(NSArray*)allDisplays;

@end

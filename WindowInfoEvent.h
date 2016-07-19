//
//  WindowInfoEvent.h
//  TrackingFramework
//
//  Created by Sylvain Malacria on 10/07/15.
//  Copyright (c) 2015 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VnrWindowInfo.h"


typedef int vnrWindowInfoEventType;
enum {
    vnrWindowAppeared,
    vnrWindowDisappeared,
    vnrWindowMoved,
    vnrWindowResized,
    vnrWindowReordered,
    vnrWindowInit,
    vnrWindowUnknown
};
@interface WindowInfoEvent : NSObject

@property VnrWindowInfo* windowInfo;

@property int layerNumber;
@property NSTimeInterval timestamp;
@property uint64 clock;

@property vnrWindowInfoEventType eventType;
@property NSArray* windows;

-(id)initWith:(VnrWindowInfo*)windowInfo
atLayerNumber:(int)layernum
 forEventType:(vnrWindowInfoEventType)event
  atTimestamp:(NSTimeInterval)time
      atClock:(uint64)clock
andAllWindows:(NSArray*)windows;

@end

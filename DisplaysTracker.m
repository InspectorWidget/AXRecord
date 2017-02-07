//
//  DisplaysTracker.m
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright (c) 2017 Christian Frisson. All rights reserved.
//

#import "DisplaysTracker.h"
#import "DisplaysInfoEvent.h"
#import "DisplaysGrabber.h"
#import "DisplayInfo.h"
#include "platform.h"



@implementation DisplaysTracker{
    NSArray* displaysInfoArray;
  
}

static void ReconfigurationCallBack (CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void *userInfo){

    NSLog(@"ReconfigurationCallBack");
    DisplaysTracker* this = (__bridge DisplaysTracker*)userInfo;
    [this update];
}

-(id)initWithXMLFileAccess:(XMLFileAccessMethods*)xml{
    self = [super init];
    if(self){
        NSLog(@"init displaysTracker");
        self.xmlFileAccess = xml;
        displaysInfoArray = [DisplaysGrabber getDisplaysList];
        CGDisplayRegisterReconfigurationCallback(ReconfigurationCallBack,CFBridgingRetain(self));
    }
    return self;
}



+(NSArray*)getCurrentDisplaysInfo{
    return [DisplaysGrabber getDisplaysList];
}

-(void)processTimer{
    [self update];
}

# pragma mark called periodically to check wether or not events should be fired
-(void)update{
    uint64 clock = os_gettime_ns();
    
    NSArray* newDisplaysInfoArray = [DisplaysGrabber getDisplaysList];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];

    for (DisplayInfo *displayInfo in newDisplaysInfoArray) {

        DisplaysInfoEvent* event = [[DisplaysInfoEvent alloc]
                initWith:displayInfo
                forEventType:displayAppeared
                atTimestamp:time
                atClock:clock
                andAllDisplays:newDisplaysInfoArray
        ];
        if([self.displaysTrackerDelegate respondsToSelector:@selector(displaysInfoEventHappened:)]){
            [self.displaysTrackerDelegate displaysInfoEventHappened:event];
        }
    }
    
    displaysInfoArray = newDisplaysInfoArray;
    
}


- (void)stop{

    CGDisplayRemoveReconfigurationCallback(ReconfigurationCallBack,CFBridgingRetain(self));
}

@end

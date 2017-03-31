//
//  VnrWindowInfo.m
//  AXRecord
//
//  Created by Sylvain Malacria on 11/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "VnrWindowInfo.h"


@implementation VnrWindowInfo


-(id)initWithFrame:(CGRect)rect
  title:(NSString*)title
  owner:(NSString*)owner
  ownerPID:(pid_t)PID
  windowID:(CGWindowID)windowID
  layer:(int)layer{
    self = [super init];
    if (self) {
        self.frame = rect;
        self.title = title;
        self.ownerName = owner;
        self.ownerPID = PID;
        self.windowID = windowID;
        self.layer = layer;
    }
    return self;
}



-(NSNumber *)windowIDNumber
{
    return [NSNumber numberWithUnsignedInt:_windowID];
}

@end

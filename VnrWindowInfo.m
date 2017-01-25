//
//  VnrWindowInfo.m
//  AXRecord
//
//  Created by Sylvain Malacria on 11/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "VnrWindowInfo.h"


@implementation VnrWindowInfo


-(id)initWithFrame:(CGRect)rect title:(NSString*)title owner:(NSString*)owner ownerPID:(pid_t)PID andWindowID:(CGWindowID)windowID{
    self = [super init];
    if (self) {
        self.frame = rect;
        self.title = title;
        self.ownerName = owner;
        self.ownerPID = PID;
        self.windowID = windowID;
    }
    return self;
}



-(NSNumber *)windowIDNumber
{
    return [NSNumber numberWithUnsignedInt:_windowID];
}

@end

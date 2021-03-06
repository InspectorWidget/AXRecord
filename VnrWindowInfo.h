//
//  VnrWindowInfo.h
//  AXRecord
//
//  Created by Sylvain Malacria on 11/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VnrWindowInfo : NSObject


@property CGRect frame;
@property BOOL isOnScreen;
@property NSString* title;
@property NSString* ownerName;
@property pid_t ownerPID;
@property CGWindowID windowID;
@property int layer;

-(id)initWithFrame:(CGRect)rect
  title:(NSString*)title
  owner:(NSString*)owner
  ownerPID:(pid_t)PID
  windowID:(CGWindowID)windowID
  layer:(int)layer;

-(NSNumber *)windowIDNumber;

@end

//
//  DisplaysTracker.h
//  AXRecord
//
//  Created by Christian Frisson on 06/02/17.
//  Copyright (c) 2017 Christian Frisson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLFileAccessMethods.h"

@protocol DisplaysTrackerDelegate <NSObject>
@required

-(void)displaysInfoEventHappened:(DisplaysInfoEvent*)displaysEvent;

@end

@interface DisplaysTracker : NSObject

@property NSTimer *timer;

@property XMLFileAccessMethods* xmlFileAccess; // The xml document corresponding to all the events
@property(nonatomic,assign)id<DisplaysTrackerDelegate> displaysTrackerDelegate;

-(id)initWithXMLFileAccess:(XMLFileAccessMethods*)xml;
// retrieve an array of current window snapshots
+(NSArray*)getCurrentDisplaysInfo;
-(void)update;

-(void)stop;

@end

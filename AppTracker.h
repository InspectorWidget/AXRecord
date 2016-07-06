//
//  AppTracker.h
//  TrackpadLogger
//
//  Created by Sylvain Malacria on 22/04/2014.
//  Copyright (c) 2014 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLFileAccessMethods.h"

@interface AppTracker : NSObject



@property XMLFileAccessMethods* xmlFileAccess; // The xml document corresponding to all the events

-(id)initWithXMLFileAccess:(XMLFileAccessMethods*)xml;

@end

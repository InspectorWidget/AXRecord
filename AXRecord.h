//
//  AXRecord.h
//  AXRecord
//
//  Created by Sylvain Malacria on 02/02/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLFileAccessMethods.h"

@interface AXRecord : NSObject

@property XMLFileAccessMethods* xmlFileAccess; // The xml document corresponding to all the events

-(id)initWithXMLFileAccess:(XMLFileAccessMethods*)xml;

+(AXUIElementRef)systemWideElement;



@end

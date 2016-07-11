//
//  UIElementUtilitiesAdditions.h
//  AXAll
//
//  Created by Sylvain Malacria on 15/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIElementUtilitiesAdditions : NSObject


/* Custom method for logging only what we are interested in */
+ (NSString *)stringDescriptionOfRelevantUIElementsBeingVerbose:(AXUIElementRef)element;

/*Custom method returning AXElementRef  located at some point */
+ (AXUIElementRef)elementAtCGPoint:(CGPoint)pointAsCGPoint withSystemWideElement:(AXUIElementRef)systemWideElement;

/*Custom method returning an NSArray* of all ancestors of a given element*/
+(NSArray*)arrayOfAncestorsOfElement:(AXUIElementRef)element;





/*Custom methods used for getting all relevant information of an element has an "opening" XML item*/
/*Still have to close the XML bracket at some points, unless we use the "beingselfclosed" version which selfclose the XML node */
+(NSString*)relevantXMLDescriptionOfElement:(AXUIElementRef)element;
+(NSString*)relevantXMLDescriptionOfElement:(AXUIElementRef)element beingSelfClosed:(BOOL)selfclosed;

+(NSString*)XMLDescriptionOfElement:(AXUIElementRef)element;
+ (NSString *)XMLDescriptionOfElement:(AXUIElementRef)element beingSelfClosed:(BOOL)selfclosed;


+(BOOL) isRelevantActionContainedInArrayOfActions:(NSArray*)listOfActions;
+(BOOL)isRelevantRole:(NSString*)elementRole;




/* Custom methods testing whether or not the specific attribute exist*/
+(BOOL)hasGivenElement:(AXUIElementRef)element attribute:(NSString*)attribute;

@end

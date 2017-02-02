//
//  UIElementUtilitiesAdditions.m
//  AXRecord
//
//  Created by Sylvain Malacria on 15/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "UIElementUtilitiesAdditions.h"
#import "UIElementUtilities.h"

@implementation UIElementUtilitiesAdditions







// -------------------------------------------------------------------------------
//	stringDescriptionOfRelevantUIElementsBeingVerbose:
//
//	Return a descriptive string of attributes and actions of a given uiElement.
// and all his relevant children
// is consider relevant if interactive, big enough, visible, etc.
// -------------------------------------------------------------------------------
+ (NSString *)stringDescriptionOfRelevantUIElementsBeingVerbose:(AXUIElementRef)element
{
    NSMutableString * 	theDescriptionStr = [NSMutableString new] ;
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;
    
    
    
    
    // display actions
    NSArray * theActions = [UIElementUtilities actionNamesOfUIElement:element];
    // Actions should contain the name of action so check weither or not this is relevant
    // and instantiate the value of isRelevant with correct value
    
    
    BOOL isRelevant= [UIElementUtilitiesAdditions isRelevantActionContainedInArrayOfActions:theActions];
    
    
    NSString* elementRole = [UIElementUtilities roleOfUIElement:element];
    if(!isRelevant){
        // element role is the role of current element
        // test wether or not the role is relevant
        // and update the value of isrelevant
        isRelevant = [UIElementUtilitiesAdditions isRelevantRole:elementRole];
    }
    
    
    if(isRelevant){
        //TODO: here we should do what we have to do.
        // either store the interesting information in a string (this one is dummy)
        NSString* dummyString = [NSString stringWithFormat:@"%@",elementRole];
        
        
        
        // and append it to the theDescriptionStr
        [theDescriptionStr appendFormat:@"%@",elementRole];
        
        for(NSString* action in theActions){
            [theDescriptionStr appendFormat:@"-%@",action];
        }
        // or write the log somewhere
        [theDescriptionStr appendFormat:@"\n"];
    }
    
    
    //todo change with test whether there is a visiblechildren attribute or not
    BOOL hasVisibleChildren = YES;
    NSArray* visibleChildren = [UIElementUtilities valueOfAttribute:NSAccessibilityVisibleChildrenAttribute ofUIElement:element];
    if(visibleChildren){
        if([visibleChildren count]==0){
            hasVisibleChildren=NO;
        }
    }
    
    
    if(hasVisibleChildren){
        
        
        CFTypeRef children = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:NSAccessibilityVisibleChildrenAttribute ofUIElement:element];
        if(children){
            if(CFGetTypeID(children)==CFArrayGetTypeID()){
                CFIndex count = CFArrayGetCount(children);
                if(count>0){
                    
                    for( CFIndex i = 0; i < count; i++ )
                    {
                        AXUIElementRef child = (AXUIElementRef) CFArrayGetValueAtIndex(children,i);
                        [theDescriptionStr appendFormat:@"%@",[UIElementUtilitiesAdditions stringDescriptionOfRelevantUIElementsBeingVerbose:child]];
                    }
                }
            }
        }
    }
    
    
    
    //do the same for visible rows and visible columns
    
    
    
    
    
    
    
    
    return theDescriptionStr;
}








#pragma mark -
#pragma mark Custom methods for writing what's interesting



// -------------------------------------------------------------------------------
//	isRelevantRole:
//
//	Return a BOOL corresponding  to YES if the role is considered "relevant"
// -------------------------------------------------------------------------------

+(BOOL)isRelevantRole:(NSString*)elementRole{
    BOOL result =NO;
    //TODO: complete this method with the actual relevant role
    result = ([elementRole rangeOfString:@"Button"].length != 0);
    //result = [elementRole containsString:@"Button"]; // requires OSX 10.10+
    result = [elementRole isEqualToString:@"Text"];
    result = [elementRole isEqualToString:@"AXButton"];
    result = [elementRole isEqualToString:@"AXButton"];
    
    return result;
}


// -------------------------------------------------------------------------------
//	isRelevantActionContainedInArrayOfActions:
//
//	Return a BOOL corresponding  to YES if the ARRAY contains one of the action considered "relevant"
// -------------------------------------------------------------------------------
+(BOOL) isRelevantActionContainedInArrayOfActions:(NSArray*)listOfActions
{
    //TODO: complete this method with the actual relevant actions
    BOOL result = NO;
    
    return result;
}






+(NSString*)relevantXMLDescriptionOfElement:(AXUIElementRef)element{
    return [UIElementUtilitiesAdditions relevantXMLDescriptionOfElement:element beingSelfClosed:NO];
}



+(NSString*)relevantXMLDescriptionOfElement:(AXUIElementRef)element beingSelfClosed:(BOOL)selfclosed{
    NSMutableString* result;
    if(element){
        result= [NSMutableString new];
        
        [result appendFormat:@"<%@ ",[UIElementUtilities roleOfUIElement:element]];
        
        NSRect frame = [UIElementUtilities frameOfUIElement:element];
        
        
        // if frame exists
        if(!NSEqualRects(frame, NSZeroRect)){
            [result appendFormat:@"x=%.0f y=%.0f w=%.0f h=%.0f ",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height];
        }
        
        
        
        
        //if contains value info
        id value = [UIElementUtilities valueOfAttribute:NSAccessibilityValueAttribute ofUIElement:element];
        if(value){
            [result appendFormat:@"value=%@ ",value];
        }
        
        
        // if contains focused info
        value = [UIElementUtilities valueOfAttribute:NSAccessibilityFocusedAttribute ofUIElement:element];
        if(value){
            [result appendFormat:@"focused=%@ ",value];
        }
        
        //if contains enabled info
        value = [UIElementUtilities valueOfAttribute:NSAccessibilityEnabledAttribute ofUIElement:element];
        if(value){
            [result appendFormat:@"enabled=%@ ",value];
        }
        
        // if contains title info
        value = [UIElementUtilities valueOfAttribute:NSAccessibilityTitleAttribute ofUIElement:element];
        if(value){
            [result appendFormat:@"title=%@ ",value];
        }
        
        // if contains label info
        value = [UIElementUtilities valueOfAttribute:NSAccessibilityLabelValueAttribute ofUIElement:element];
        if(value){
            [result appendFormat:@"label=%@ ",value];
        }
        
        //if contains help info
        value = [UIElementUtilities valueOfAttribute:NSAccessibilityHelpAttribute ofUIElement:element];
        if(value){
            [result appendFormat:@"help=%@ ",value];
        }
        
        
        
        
        
        if(selfclosed){
            [result appendString:@"/"];
        }
        [result appendString:@">\n"];
    }
    
    
    
    
    return result;
}

+(NSString*)XMLDescriptionOfElement:(AXUIElementRef)element{
    return [UIElementUtilitiesAdditions XMLDescriptionOfElement:element beingSelfClosed:NO];
}



+ (NSString *)XMLDescriptionOfElement:(AXUIElementRef)element beingSelfClosed:(BOOL)selfclosed
{
    NSMutableString * 	theDescriptionStr = [NSMutableString new] ;
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;
    
    
    
    
    [theDescriptionStr appendFormat:@"<%@ ",[UIElementUtilities roleOfUIElement:element]];
    
    // display attributes
    theNames = [UIElementUtilities attributeNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName = NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            
            // Add string
            [theDescriptionStr appendFormat:@"%@='%@' ", theName,  [UIElementUtilities descriptionForUIElement:element attribute:theName beingVerbose:false]];
            

        }
        
    }
    
    // display actions
    theNames = [UIElementUtilities actionNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName 		= NULL;
           	NSString *	theDesc 		= NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            // Grab description
            theDesc = [UIElementUtilities descriptionOfAction:theName ofUIElement:element];
            
            // Add string
            [theDescriptionStr appendFormat:@"%@='%@' ", theName, theDesc];
        }
        
    }
    
    if(selfclosed){
        [theDescriptionStr appendString:@"/"];
    }
    [theDescriptionStr appendString:@">\n"];
    
    return theDescriptionStr;
}





// -------------------------------------------------------------------------------
//	elementAtCGPoint: withSystemWideElement:
// -------------------------------------------------------------------------------
+ (AXUIElementRef)elementAtCGPoint:(CGPoint)pointAsCGPoint withSystemWideElement:(AXUIElementRef)systemWideElement
{
    
    AXUIElementRef newElement = NULL;
    
    // Ask Accessibility API for UI Element under the mouse
    if (AXUIElementCopyElementAtPosition( systemWideElement, pointAsCGPoint.x, pointAsCGPoint.y, &newElement ) == kAXErrorSuccess)
    {
        
    }
    
    return newElement;
}








// -------------------------------------------------------------------------------
//	arrayOfAncestorsOfElement:element
//
//	Return an array with all ancestors in it
// -------------------------------------------------------------------------------
+(NSArray*)arrayOfAncestorsOfElement:(AXUIElementRef)element{
    NSArray *lineage = [NSArray array];
    AXUIElementRef parent = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:NSAccessibilityParentAttribute ofUIElement:element];
    
    if (parent != NULL) {
        lineage = [self arrayOfAncestorsOfElement:parent];
    }
    return [lineage arrayByAddingObject:(__bridge id)element];
}





/**
 * method checks whether or not the AXUIelementRef has an attribute
 * for the given attribute
 * return yes if true, no otherwise
 @param AXUIElementRef the element we are interested in
 @return BOOL yes if the element has the given attribute
 */
+(BOOL)hasGivenElement:(AXUIElementRef)element attribute:(NSString*)attribute{
    id attributeValue = [UIElementUtilities valueOfAttribute:attribute ofUIElement:element];
    return (attributeValue!=nil);
}



@end

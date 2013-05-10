//
//  TiPassbookPassProxy.m
//  passbook
//
//  Created by Jonathan Alter on 5/8/13.
//
//

#import <PassKit/PassKit.h>
#import "TiPassbookPassProxy.h"
#import "TiBlob.h"

@implementation TiPassbookPassProxy

@synthesize pass = _pass;

-(TiPassbookPassProxy *)initWithPass:(PKPass *)pass pageContext:(id<TiEvaluator>)context
{
    NSLog(@"TiPassbookPassProxy initWithPass");
    if (self = [super _initWithPageContext:context]) {
        _pass = [pass retain];
    }
    return self;
}

-(TiPassbookPassProxy*)initWithData:(NSData *)data pageContext:(id<TiEvaluator>)context
{
    NSLog(@"TiPassbookPassProxy initWithData");
    
    NSError *error = nil;
    PKPass *pass = [[PKPass alloc] initWithData:data error:&error];
    
    if (error) {
        NSLog(@"[ERROR] initWithData: %@", error);
        return nil;
    } else {
        return [self initWithPass:pass pageContext:context];
    }
}

-(void)dealloc
{
    RELEASE_TO_NIL(_pass);
    [super dealloc];
}

#pragma mark Public APIs

-(id)localizedValueForFieldKey:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSString);
    return [_pass localizedValueForFieldKey:arg];
}

#pragma mark Properties

#define MAKE_READONLY_PROP(obj,name) \
-(id)name \
{\
return [obj name];\
}\

MAKE_READONLY_PROP(_pass, passURL);

MAKE_READONLY_PROP(_pass, authenticationToken);
MAKE_READONLY_PROP(_pass, passTypeIdentifier);
MAKE_READONLY_PROP(_pass, serialNumber);
MAKE_READONLY_PROP(_pass, webServiceURL);

MAKE_READONLY_PROP(_pass, localizedName);
MAKE_READONLY_PROP(_pass, localizedDescription);
MAKE_READONLY_PROP(_pass, organizationName);
MAKE_READONLY_PROP(_pass, relevantDate);

-(TiBlob*)icon
{
    return [[[TiBlob alloc] initWithImage:[_pass icon]] autorelease];
}


-(void)test:(id)args
{
    NSLog(@"TEST");
}

@end

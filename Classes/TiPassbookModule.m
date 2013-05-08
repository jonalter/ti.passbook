/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */

//#import <PassKit/PassKit.h>
#import "TiPassbookModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "TiPassbookPassProxy.h"

@implementation TiPassbookModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"e46dcae2-4553-4ebb-9fe2-1b234776727a";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.passbook";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
    _passLibrary = [[PKPassLibrary alloc] init];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
    RELEASE_TO_NIL(_passLibrary);
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

//MAKE_SYSTEM_PROP(ADDED_PASSES, PKPassLibraryAddedPassesUserInfoKey);
//MAKE_SYSTEM_PROP(REMOVED_PASS, PKPassLibraryRemovedPassInfosUserInfoKey);
//MAKE_SYSTEM_PROP(REPLACEMENT_PASSES, PKPassLibraryReplacementPassesUserInfoKey);
//MAKE_SYSTEM_PROP(PASS_TYPE, PKPassLibraryPassTypeIdentifierUserInfoKey);
//MAKE_SYSTEM_PROP(SERIAL_NUMBER, PKPassLibrarySerialNumberUserInfoKey);


-(BOOL)isPassLibraryAvailable:(id)args
{
    return NUMBOOL([PKPassLibrary isPassLibraryAvailable]);
}

-(TiPassbookPassProxy *)addPass:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    TiBlob *blob = [args objectForKey:@"pass"];
    ENSURE_TYPE(blob, TiBlob);
    
    NSError *error = nil;
    PKPass *pass = [[PKPass alloc] initWithData:blob.data error:&error];
    
    if (error) {
        NSLog(@"ERROR in addPass");
    } else {
        NSLog(@"ALL GOOD in addPass");
    }
    
    PKAddPassesViewController *addPassVC = [[PKAddPassesViewController alloc] initWithPass:pass];
    [[TiApp controller] presentViewController:addPassVC animated:YES completion:^{}];
    
    return [[[TiPassbookPassProxy alloc] initWithPass:pass pageContext:[self executionContext]] autorelease];
}

-(BOOL)containsPass:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    TiBlob *blob = [args objectForKey:@"pass"];
    ENSURE_TYPE(blob, TiBlob);
    
    NSError *error = nil;
    PKPass *pass = [[PKPass alloc] initWithData:blob.data error:&error];
    
    if (error) {
        NSLog(@"ERROR in addPass");
    } else {
        NSLog(@"ALL GOOD in addPass");
    }
    
    return NUMBOOL([_passLibrary containsPass:pass]);
}

-(void)removePass:(id)args
{
    // Need to take PKPass or TiPassbookPassProxy
    ENSURE_SINGLE_ARG(args, NSDictionary);
    TiBlob *blob = [args objectForKey:@"pass"];
    ENSURE_TYPE(blob, TiBlob);
    
    NSError *error = nil;
    PKPass *pass = [[PKPass alloc] initWithData:blob.data error:&error];
    
    if (error) {
        NSLog(@"ERROR in addPass");
    } else {
        NSLog(@"ALL GOOD in addPass");
    }
    
    [_passLibrary removePass:pass];
}

-(BOOL)replacePassWithPass:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    TiBlob *blob = [args objectForKey:@"pass"];
    NSError *error = nil;
    PKPass *pass = [[PKPass alloc] initWithData:blob.data error:&error];
    
    if (error) {
        NSLog(@"ERROR in addPass");
    } else {
        NSLog(@"ALL GOOD in addPass");
    }
    
    return NUMBOOL([_passLibrary replacePassWithPass:pass]);
}

-(NSArray *)passes
{
    NSArray *pkPasses = [_passLibrary passes];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[pkPasses count]];
    
    [pkPasses enumerateObjectsUsingBlock:^(PKPass *pkPass, NSUInteger idx, BOOL *stop){
        [result addObject:[[[TiPassbookPassProxy alloc] initWithPass:pkPass pageContext:[self executionContext]] autorelease]];
    }];
    
    return result;
}

-(TiPassbookPassProxy *)passWithPassTypeIdentifierAndSerialNumber:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    NSString *passTypeIdentifier = [args objectForKey:@"passTypeIdentifier"];
    NSString *serialNumber = [args objectForKey:@"serialNumber"];
    
    ENSURE_STRING(passTypeIdentifier);
    ENSURE_STRING(serialNumber);
    
    PKPass *pkPass = [_passLibrary passWithPassTypeIdentifier:passTypeIdentifier serialNumber:serialNumber];

    if (!pkPass) {
        return nil;
    }
    
    return [[[TiPassbookPassProxy alloc] initWithPass:pkPass pageContext:[self executionContext]] autorelease];
}

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

@end

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
    
    // Listen for PKLibraryEvents
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passLibraryDidChange:) name:PKPassLibraryDidChangeNotification object:_passLibrary];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
    // Listening for PKLibraryEvents
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
    RELEASE_TO_NIL(_passLibrary);
    RELEASE_TO_NIL(_addPassCloseCallback);
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

//#pragma mark - Listener Notifications
//
//-(void)_listenerAdded:(NSString *)type count:(int)count
//{
//	if (count == 1 && [type isEqualToString:@"change"])
//	{
////		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passLibraryDidChange:) name:PKPassLibraryDidChangeNotification object:_passLibrary];
//	}
//}
//
//-(void)_listenerRemoved:(NSString *)type count:(int)count
//{
//	if (count == 0 && [type isEqualToString:@"change"])
//	{
////		[[NSNotificationCenter defaultCenter] removeObserver:self];
//	}
//}

#pragma mark Listener Notifications

-(void)passLibraryDidChange:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSArray *passArray;
    
    if (passArray = [userInfo objectForKey:PKPassLibraryAddedPassesUserInfoKey]) {
        NSLog(@"Added Passes");
        
        NSDictionary *event = [self pkPassArrayToEventDictionary:passArray];
        [self fireEvent:@"addedpasses" withObject:event];
    }
    
    if (passArray = [userInfo objectForKey: PKPassLibraryRemovedPassInfosUserInfoKey]) {
        NSLog(@"Removed Passes");
        
        NSDictionary *event = [self passIdArrayToEventDictionary:passArray];
        [self fireEvent:@"removedpasses" withObject:event];
    }
    
    if (passArray = [userInfo objectForKey:PKPassLibraryReplacementPassesUserInfoKey]) {
        NSLog(@"Replacement Passes");
        
        NSDictionary *event = [self pkPassArrayToEventDictionary:passArray];
        [self fireEvent:@"replacedpasses" withObject:event];
    }

}

-(NSDictionary *)pkPassArrayToEventDictionary:(NSArray *)passArray
{
    NSMutableArray *passes = [NSMutableArray arrayWithCapacity:[passArray count]];
    for (PKPass *pkPass in passArray) {
        [passes addObject:[[[TiPassbookPassProxy alloc] initWithPass:pkPass pageContext:[self executionContext]] autorelease]];
    }
    return [NSDictionary dictionaryWithObject:passes forKey:@"passes"];
}

-(NSDictionary *)passIdArrayToEventDictionary:(NSArray *)passArray
{
    NSMutableArray *passes = [NSMutableArray arrayWithCapacity:[passArray count]];
    for (NSDictionary *passDict in passArray) {
        NSLog(@"SN: %@", [passDict objectForKey:PKPassLibrarySerialNumberUserInfoKey]);
        
        [passes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           [passDict objectForKey:PKPassLibraryPassTypeIdentifierUserInfoKey], @"passTypeIdentifier",
                           [passDict objectForKey:PKPassLibrarySerialNumberUserInfoKey], @"serialNumber",
                           nil]];
    }
    return [NSDictionary dictionaryWithObject:passes forKey:@"passIds"];
}

#pragma mark - PKAddPassesViewControllerDelegate

-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller
{
    NSLog(@"DISMISSING VC");
    
    [UIView animateWithDuration:0.5 animations:^{
        controller.view.alpha = 0;
    } completion:^(BOOL b){
        [controller dismissViewControllerAnimated:YES completion:^{}];
        controller.view.alpha = 1;
    }];
    
    if (_addPassCloseCallback) {
        [_addPassCloseCallback call:[NSArray array] thisObject:nil];
    }
}

#pragma mark - Public APIs

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
    // User should check for pass in library with containsPass before adding
    // Will only be called with DATA
    ENSURE_ARRAY(args);
    NSDictionary *dict = [args objectAtIndex:0];
    
    KrollCallback *cb = nil;
    if ([args count] > 1) {
        cb = [args objectAtIndex:1];
    }
    
    ENSURE_DICT(dict);
    TiBlob *blob = [dict objectForKey:@"pass"];
    ENSURE_TYPE(blob, TiBlob);
    
    ENSURE_TYPE_OR_NIL(cb, KrollCallback);
    if (cb) {
        _addPassCloseCallback = [cb retain];
    }
    
    NSError *error = nil;
    PKPass *pass = [[PKPass alloc] initWithData:blob.data error:&error];
    
    if (error) {
        NSLog(@"ERROR in addPass");
    } else {
        NSLog(@"ALL GOOD in addPass");
    }
    
    PKAddPassesViewController *addPassVC = [[PKAddPassesViewController alloc] initWithPass:pass];
    [addPassVC setDelegate:self];
    [[TiApp controller] presentViewController:addPassVC animated:YES completion:^{}];
    
    return [[[TiPassbookPassProxy alloc] initWithPass:pass pageContext:[self executionContext]] autorelease];
}

-(BOOL)containsPass:(id)args
{
    // No Entitlement Needed
    // Will only be called with DATA
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
    // Need to take PKPass or TiPassbookPassProxy ???
    // Will only be called with a TiPassbookPassProxy
    ENSURE_SINGLE_ARG(args, NSDictionary);
    TiPassbookPassProxy *pass = [args objectForKey:@"pass"];
    ENSURE_TYPE(pass, TiPassbookPassProxy);
    
    [_passLibrary removePass:[pass pass]];
}

-(BOOL)replacePassWithPass:(id)args
{
    // Will only be called with DATA
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
    // Needs Entitlement
    // No order
    // Should we sort them?
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

-(void)showPass:(id)args
{
    // Must be pass from library
    // Will not open if not in library
    // Will only be called with TiPassbookPassProxy
    ENSURE_SINGLE_ARG(args, NSDictionary);
    TiPassbookPassProxy *pass = [args objectForKey:@"pass"];
    ENSURE_TYPE(pass, TiPassbookPassProxy);
    
    PKPass *pkPass = [pass pass];
    
    [[UIApplication sharedApplication] openURL:[pkPass passURL]];
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

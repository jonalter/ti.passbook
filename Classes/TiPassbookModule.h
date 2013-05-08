/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */

#import <PassKit/PassKit.h>
#import "TiModule.h"

@interface TiPassbookModule : TiModule 
{
@private
    PKPassLibrary *_passLibrary;
}

@property(readonly, nonatomic) NSArray *passes;

@end

//
//  TiPassbookPassProxy.h
//  passbook
//
//  Created by Jonathan Alter on 5/8/13.
//
//

#import <Foundation/Foundation.h>
#import "TiProxy.h"

@interface TiPassbookPassProxy : TiProxy
{
@private
    PKPass *_pass;
}
@property(readonly, nonatomic) NSString *serialNumber;

-(TiPassbookPassProxy *)initWithPass:(PKPass *) pageContext:(id<TiEvaluator>)context;

@end

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
}
@property(readonly, nonatomic) PKPass *pass;

-(TiPassbookPassProxy *)initWithPass:(PKPass *)pass pageContext:(id<TiEvaluator>)context;

@end

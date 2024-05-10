//
//  PTPOperationRequestPrivateData.m
//  PTPPassThrough
//
//  Created by Danil Korotenko on 5/10/24.
//

#import "PTPOperationRequestPrivateData.h"

@implementation PTPOperationRequestPrivateData

- (id)init
{
    if ( ( self = [super init] ) )
    {
        self.parameters = (unsigned int*)calloc( 5, sizeof( unsigned int ) );
    }

    return self;
}

- (void)dealloc
{
    free( self.parameters );
}

@end

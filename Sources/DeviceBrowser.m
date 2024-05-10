//
//  DeviceBrowser.m
//  PTPPassThrough
//
//  Created by Danil Korotenko on 5/10/24.
//

#import "DeviceBrowser.h"

@interface DeviceBrowser ()

@end

@implementation DeviceBrowser

- (instancetype)init
{
    self = [super initWithWindowNibName:@"DeviceBrowser"];
    if (self)
    {
        [self window]; // load window
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

}

@end

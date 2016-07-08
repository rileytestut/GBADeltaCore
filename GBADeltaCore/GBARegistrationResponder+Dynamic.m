//
//  GBARegistrationResponder+Dynamic.m
//  GBADeltaCore
//
//  Created by Riley Testut on 7/8/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

#import "GBARegistrationResponder+Dynamic.h"

@import DeltaCore;

@implementation GBARegistrationResponder (Dynamic)

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeltaRegistrationRequest:) name:DeltaRegistrationRequestNotification object:nil];
}

@end

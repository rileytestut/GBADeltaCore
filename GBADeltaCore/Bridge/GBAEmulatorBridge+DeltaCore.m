//
//  GBAEmulatorBridge+DeltaCore.m
//  
//
//  Created by Riley Testut on 11/15/21.
//

#import "GBAEmulatorBridge+DeltaCore.h"
#import "GBAEmulatorBridge+Private.h"
#import "GBATypes.h"

@import DeltaCore;

@implementation GBAEmulatorBridge (DeltaCore)

- (BOOL)addCheatCode:(NSString *)cheatCode type:(NSString *)type
{
    NSArray<NSString *> *codes = [cheatCode componentsSeparatedByString:@"\n"];
    for (NSString *code in codes)
    {
        NSMutableCharacterSet *legalCharactersSet = [NSMutableCharacterSet hexadecimalCharacterSet];
        [legalCharactersSet addCharactersInString:@" "];
        
        if ([code rangeOfCharacterFromSet:[legalCharactersSet invertedSet]].location != NSNotFound)
        {
            return NO;
        }
        
        if ([type isEqualToString:CheatTypeActionReplay] || [type isEqualToString:CheatTypeGameShark])
        {
            NSString *sanitizedCode = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if (sanitizedCode.length != 16)
            {
                return NO;
            }
            
            [self addGameSharkCheatCode:sanitizedCode];
        }
        else if ([type isEqualToString:CheatTypeCodeBreaker])
        {
            if (code.length != 13)
            {
                return NO;
            }
            
            [self addCodeBreakerCheatCode:code];
        }
    }
    
    return YES;
}

@end

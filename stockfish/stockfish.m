//
//  stockfish.m
//  stockfish
//
//  Created by Douglas Pedley on 12/27/20.
//

#import "stockfish.h"
#import "FishWrap.h"

@interface stockfish ()
@property (nonatomic, strong) FishWrap *fishWrap;
@end

@implementation stockfish

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fishWrap = [[FishWrap alloc] init];
    }
    return self;
}

-(void)evaluateFEN:(NSString *)fen {
    [self.fishWrap sendUCICommand:fen];
}


@end

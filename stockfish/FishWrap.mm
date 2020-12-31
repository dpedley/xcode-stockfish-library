//
//  FishWrap.m
//  stockfish
//
//  Created by Douglas Pedley on 12/28/20.
//

#import <Foundation/Foundation.h>
#import "FishWrap.h"
#include <iostream>
#include "bitboard.h"
#include "endgame.h"
#include "position.h"
#include "search.h"
#include "thread.h"
#include "tt.h"
#include "uci.h"
#include "syzygy/tbprobe.h"
#include <sstream>
#include "StockfishObjC.h"

namespace PSQT {
  void init();
}
const char* StartFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
std::stringstream fishOut;

@interface FishLoop : NSOperation
@property (nonatomic, strong) NSMutableArray *commands;
@property (nonatomic, weak) NSObject<TalksToFish> *communicationDelegate;
@end

@implementation FishLoop

- (instancetype)initWithTalksTo:(NSObject *)talksTo {
    self = [super init];
    if (self) {
        self.commands = [@[] mutableCopy];
        if ([self.communicationDelegate conformsToProtocol:@protocol(TalksToFish)]) {
            self.communicationDelegate = (NSObject<TalksToFish> *)talksTo;
        }
    }
    return self;
}

- (void)appendCommand:(NSString *)command {
    @synchronized (self.commands) {
        [self.commands addObject:command];
    }
}

- (BOOL)isBestMove:(NSString *)message {
    if (message==nil || message.length == 0) {
        return NO;
    }
    if (message.length > 9 && [[message substringToIndex:9] isEqualToString:@"bestmove "]) {
        return YES;
    }
    return NO;
}

- (BOOL)isInfo:(NSString *)message {
    if (message==nil || message.length == 0) {
        return NO;
    }
    if (message.length > 5 && [[message substringToIndex:5] isEqualToString:@"info "]) {
        return YES;
    }
    return NO;
}

- (void)startAquaman {
    [NSThread detachNewThreadWithBlock:^{
        do {
            std::string glub = fishOut.str();
            fishOut.clear();
            fishOut.str(std::string());
            if (glub.size() > 0) {
                NSString *messageLines = [NSString stringWithUTF8String:glub.c_str()];
                NSArray *messages = [messageLines componentsSeparatedByString:@"\n"];
                for (int i=0; i<messages.count; i++) {
                    NSString *message = messages[i];
                    if ([self isBestMove:message]) {
                        [self.communicationDelegate stockfishBestMove:message];
                        Search::clear();
                    } else if ([self isInfo:message]) {
                        [self.communicationDelegate stockfishInfo:message];
                    } else {
                        [self.communicationDelegate stockfishError:message];
                    }
                }
            }
            [NSThread sleepForTimeInterval:0.05];
        } while (!self.cancelled);
    }];
}

- (void)main {
    Position pos;
    std::string token;
    StateListPtr states(new std::deque<StateInfo>(1));
    Options["Use NNUE"] = false;
    // Initialize Stockfish classes
    UCI::init(Options);
    Tune::init();
    PSQT::init();
    Bitboards::init();
    Position::init();
    Bitbases::init();
    Endgames::init();
    Threads.set(size_t(Options["Threads"]));
    Search::clear(); // After threads are up
    Eval::NNUE::init();
    pos.set(StartFEN, false, &states->back(), Threads.main());
    [self startAquaman];
    do {
        NSString *command = [self.commands firstObject];
        if (command != nil) {
            @synchronized (self.commands) {
                [self.commands removeObjectAtIndex:0];
            }
            // Call UCI
            std::string cmd = std::string([command UTF8String]);
            UCI::processCommand(token, cmd, pos, states);
        } else {
            [NSThread sleepForTimeInterval:0.05];
        }
    } while (!self.cancelled);
}

@end

@interface FishWrap()
@property (nonatomic, strong) FishLoop *fishLoop;
@end

@implementation FishWrap
- (NSString *)sendUCICommand:(NSString *)uci {
    [self.fishLoop appendCommand:uci];
    return @"";
}

-(instancetype)initWithTalksTo:(NSObject *)talksTo {
    self = [super init];
    if (self) {
        self.fishLoop = [[FishLoop alloc] initWithTalksTo:talksTo];
        [NSThread detachNewThreadWithBlock:^{
            [self.fishLoop start];
        }];
    }
    return self;
}
@end

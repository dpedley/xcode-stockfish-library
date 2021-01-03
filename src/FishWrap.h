#import <Foundation/Foundation.h>

@interface FishWrap : NSObject
- (NSString *)sendUCICommand:(NSString *)uci;
-(instancetype)initWithTalksTo:(NSObject *)talksTo;
@end


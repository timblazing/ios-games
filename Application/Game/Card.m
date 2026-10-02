#import "Card.h"
@implementation Card
- (instancetype)initWithIdentifier:(NSInteger)i {
    if ((self = [super init])) {
        _identifier = i;
    }
    return self;
}
- (NSInteger)rank {
    return self.identifier % 13 + 1;
}
- (NSInteger)suit {
    return self.identifier / 13;
}
- (BOOL)red {
    return self.suit < 2;
}
- (NSString *)rankText {
    return @[ @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K" ][self.rank - 1];
}
- (NSString *)suitText {
    return @[ @"♥", @"♦", @"♣", @"♠" ][self.suit];
}
@end

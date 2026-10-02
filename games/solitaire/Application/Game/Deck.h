#import "Card.h"
@interface Deck : NSObject
+ (NSMutableArray<Card *> *)shuffledCards;
@end

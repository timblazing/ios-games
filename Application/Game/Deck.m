#import "Deck.h"
#include <stdlib.h>
@implementation Deck
+ (NSMutableArray<Card *> *)shuffledCards {
    NSMutableArray *cards = [NSMutableArray array];
    for (NSInteger i = 0; i < 52; i++)
        [cards addObject:[[Card alloc] initWithIdentifier:i]];
    for (NSUInteger i = 51; i > 0; i--)
        [cards exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((uint32_t)i + 1)];
    return cards;
}
@end

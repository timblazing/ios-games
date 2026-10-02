#import "../Game/Card.h"
#import <SpriteKit/SpriteKit.h>
@interface CardNode : SKSpriteNode
@property(nonatomic, strong) Card *card;
@property(nonatomic) NSInteger pile;
@property(nonatomic) NSInteger index;
- (instancetype)initWithCard:(Card *)card size:(CGSize)size;
- (void)refreshWithSize:(CGSize)size back:(NSString *)back animated:(BOOL)animated;
+ (NSArray<NSString *> *)availableBacks;
@end

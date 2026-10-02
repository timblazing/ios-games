#import "CardNode.h"
#import <UIKit/UIKit.h>
@implementation CardNode
+ (NSArray<NSString *> *)availableBacks {
    NSString *dir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CardBacks"];
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL])
        if ([@[ @"png", @"jpg", @"jpeg" ] containsObject:name.pathExtension.lowercaseString])
            [names addObject:name];
    return [names sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}
- (instancetype)initWithCard:(Card *)card size:(CGSize)size {
    if ((self = [super initWithColor:[UIColor clearColor] size:size])) {
        _card = card;
        self.name = @"card";
    }
    return self;
}
+ (SKTexture *)textureForCard:(Card *)card size:(CGSize)size back:(NSString *)back {
    static NSCache *cache;
    if (!cache) {
        cache = [NSCache new];
        cache.countLimit = 110;
    }
    NSString *key =
        [NSString stringWithFormat:@"%ld-%d-%.0f-%.0f-%@", (long)(card.faceUp ? card.identifier : -1),
                                   card.faceUp, size.width, size.height, back];
    SKTexture *texture = [cache objectForKey:key];
    if (texture)
        return texture;
    // Cap to 2x; a complete face atlas stays comfortably small on the A7.
    UIGraphicsBeginImageContextWithOptions(size, NO, MIN(2, [UIScreen mainScreen].scale));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectInset((CGRect){CGPointZero, size}, 2, 2);
    UIBezierPath *shape = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:7];
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2), 2, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    [[UIColor colorWithWhite:0.93 alpha:1] setFill];
    [shape fill];
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    [shape addClip];
    if (!card.faceUp) {
        [[UIColor colorWithRed:0.13 green:0.18 blue:0.24 alpha:1] setFill];
        UIRectFill(rect);
        NSString *path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CardBacks"]
            stringByAppendingPathComponent:back ?: @"default.png"];
        UIImage *art = [UIImage imageWithContentsOfFile:path];
        if (art && art.size.width > 0 && art.size.height > 0) {
            CGFloat scale = MAX(rect.size.width / art.size.width, rect.size.height / art.size.height);
            CGSize target = CGSizeMake(art.size.width * scale, art.size.height * scale);
            [art drawInRect:CGRectMake(CGRectGetMidX(rect) - target.width / 2,
                                       CGRectGetMidY(rect) - target.height / 2, target.width, target.height)];
        }
        [[UIColor colorWithWhite:1 alpha:0.18] setStroke];
        UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 5, 5)
                                                          cornerRadius:4];
        border.lineWidth = 1;
        [border stroke];
    } else {
        UIColor *ink = card.red ? [UIColor colorWithRed:0.69 green:0.19 blue:0.25 alpha:1]
                                : [UIColor colorWithWhite:0.12 alpha:1];
        NSDictionary *corner = @{
            NSFontAttributeName : [UIFont systemFontOfSize:size.width * 0.19 weight:UIFontWeightSemibold],
            NSForegroundColorAttributeName : ink
        };
        NSString *label = [NSString stringWithFormat:@"%@%@", card.rankText, card.suitText];
        [label drawAtPoint:CGPointMake(8, 6) withAttributes:corner];
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, size.width, size.height);
        CGContextRotateCTM(ctx, M_PI);
        [label drawAtPoint:CGPointMake(8, 6) withAttributes:corner];
        CGContextRestoreGState(ctx);
        NSDictionary *center = @{
            NSFontAttributeName : [UIFont systemFontOfSize:size.width * 0.45],
            NSForegroundColorAttributeName : ink
        };
        CGSize symbol = [card.suitText sizeWithAttributes:center];
        [card.suitText
               drawAtPoint:CGPointMake((size.width - symbol.width) / 2, (size.height - symbol.height) / 2)
            withAttributes:center];
    }
    CGContextRestoreGState(ctx);
    texture = [SKTexture textureWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    [cache setObject:texture forKey:key];
    return texture;
}
- (void)refreshWithSize:(CGSize)size back:(NSString *)back animated:(BOOL)animated {
    SKTexture *next = [CardNode textureForCard:self.card size:size back:back];
    self.size = size;
    if (animated && self.texture && self.texture != next) {
        [self removeActionForKey:@"flip"];
        self.xScale = 1;
        SKAction *close = [SKAction scaleXTo:0 duration:0.07];
        SKAction *open = [SKAction scaleXTo:1 duration:0.09];
        [self runAction:[SKAction sequence:@[
                  close, [SKAction runBlock:^{
                      self.texture = next;
                  }],
                  open
              ]]
                withKey:@"flip"];
    } else {
        [self removeActionForKey:@"flip"];
        self.xScale = 1;
        self.texture = next;
    }
}
@end

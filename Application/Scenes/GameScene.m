#import "GameScene.h"
#import "../Nodes/CardNode.h"
#import "../Nodes/PileNode.h"
@interface GameScene ()
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, CardNode *> *cards;
@property(nonatomic, strong) NSMutableArray<PileNode *> *slots;
@property(nonatomic) CGSize cardSize;
@property(nonatomic) NSInteger selectedPile;
@property(nonatomic) NSInteger selectedIndex;
@property(nonatomic) CGPoint touchStart;
@property(nonatomic) BOOL dragging;
@property(nonatomic, strong) NSArray<CardNode *> *lifted;
@property(nonatomic, strong) NSArray<NSValue *> *origins;
@property(nonatomic, strong) UITouch *activeTouch;
@end
@implementation GameScene
- (instancetype)initWithSize:(CGSize)size {
    if ((self = [super initWithSize:size])) {
        self.backgroundColor = [SKColor blackColor];
        self.scaleMode = SKSceneScaleModeResizeFill;
        _cards = [NSMutableDictionary dictionary];
        _slots = [NSMutableArray array];
        _selectedPile = -1;
    }
    return self;
}
- (CGFloat)margin {
    return MAX(14, self.size.width * 0.025);
}
- (CGFloat)gap {
    return (self.size.width - 2 * self.margin - 7 * self.cardSize.width) / 6;
}
- (CGPoint)originForPile:(NSInteger)p {
    CGFloat step = self.cardSize.width + self.gap, x = self.margin + self.cardSize.width / 2;
    if (p == 0)
        return CGPointMake(x, self.size.height - self.cardSize.height / 2 - 8);
    if (p == 1)
        return CGPointMake(x + step, self.size.height - self.cardSize.height / 2 - 8);
    if (p < 6)
        return CGPointMake(x + (p + 1) * step, self.size.height - self.cardSize.height / 2 - 8);
    return CGPointMake(x + (p - 6) * step, self.size.height - self.cardSize.height * 1.5 - 32);
}
- (CGPoint)positionForPile:(NSInteger)p index:(NSInteger)i {
    CGPoint pos = [self originForPile:p];
    if (p >= 6) {
        NSArray *pile = self.game.piles[p];
        CGFloat desired = 0;
        for (NSInteger j = 0; j < (NSInteger)pile.count - 1; j++)
            desired += ((Card *)pile[j]).faceUp ? self.cardSize.height * 0.24 : self.cardSize.height * 0.105;
        CGFloat room = MAX(0, pos.y - self.cardSize.height / 2 - 12),
                factor = desired > 0 ? MIN(1, room / desired) : 1;
        for (NSInteger j = 0; j < i; j++)
            pos.y -= (((Card *)pile[j]).faceUp ? self.cardSize.height * 0.24 : self.cardSize.height * 0.105) *
                     factor;
    }
    return pos;
}
- (void)didChangeSize:(CGSize)oldSize {
    if (self.game) {
        [self cancelInteraction];
        [self refreshAnimated:NO];
    }
}
- (void)refreshAnimated:(BOOL)animated {
    if (!self.game)
        return;
    self.cardSize = CGSizeMake(MIN(112, (self.size.width - 2 * self.margin - 6 * 12) / 7), 0);
    self.cardSize = CGSizeMake(self.cardSize.width, self.cardSize.width * 1.4);
    for (SKNode *s in self.slots)
        [s removeFromParent];
    [self.slots removeAllObjects];
    for (NSInteger p = 0; p < 13; p++) {
        NSString *label = p == 0 ? @"↻" : (p >= 2 && p < 6 ? @[ @"♥", @"♦", @"♣", @"♠" ][p - 2] : @"");
        PileNode *slot = [[PileNode alloc] initWithSize:self.cardSize label:label];
        slot.position = [self originForPile:p];
        [self.slots addObject:slot];
        [self addChild:slot];
    }
    NSString *back = [[NSUserDefaults standardUserDefaults] stringForKey:@"cardBack"] ?: @"default.png";
    BOOL motion = animated && !UIAccessibilityIsReduceMotionEnabled();
    for (NSInteger p = 0; p < 13; p++)
        for (NSInteger i = 0; i < (NSInteger)self.game.piles[p].count; i++) {
            Card *card = self.game.piles[p][i];
            CardNode *node = self.cards[@(card.identifier)];
            if (!node) {
                node = [[CardNode alloc] initWithCard:card size:self.cardSize];
                node.position = [self originForPile:0];
                self.cards[@(card.identifier)] = node;
                [self addChild:node];
            }
            node.card = card;
            node.pile = p;
            node.index = i;
            node.zPosition = 10 + p * 52 + i;
            node.colorBlendFactor = 0;
            node.alpha = 1;
            node.hidden = p < 6 && i < (NSInteger)self.game.piles[p].count - 1;
            [node refreshWithSize:self.cardSize back:back animated:motion];
            [node removeActionForKey:@"move"];
            [node removeActionForKey:@"victory"];
            node.yScale = 1;
            CGPoint target = [self positionForPile:p index:i];
            if (motion) {
                SKAction *move = [SKAction moveTo:target duration:0.18];
                move.timingMode = SKActionTimingEaseOut;
                [node runAction:move withKey:@"move"];
            } else
                node.position = target;
        }
    [self showSelection];
}
- (CardNode *)cardAt:(CGPoint)point {
    CardNode *best = nil;
    for (SKNode *node in [self nodesAtPoint:point])
        if ([node isKindOfClass:[CardNode class]] && !node.hidden &&
            (!best || node.zPosition > best.zPosition))
            best = (CardNode *)node;
    return best;
}
- (NSInteger)pileAt:(CGPoint)point {
    if (point.y > [self originForPile:6].y + self.cardSize.height / 2 + 10) {
        for (NSInteger p = 0; p < 6; p++)
            if (CGRectContainsPoint(CGRectInset(self.slots[p].frame, -8, -8), point))
                return p;
        return -1;
    }
    for (NSInteger p = 6; p < 13; p++)
        if (fabs(point.x - [self originForPile:p].x) < (self.cardSize.width + self.gap) / 2)
            return p;
    return -1;
}
- (void)showSelection {
    for (NSInteger p = 0; p < (NSInteger)self.slots.count; p++)
        [self.slots[p] setHighlighted:self.selectedPile >= 0 && [self.game canMoveFrom:self.selectedPile
                                                                                 index:self.selectedIndex
                                                                                    to:p]];
    for (CardNode *node in self.cards.allValues) {
        node.color = [SKColor colorWithRed:0.5 green:0.7 blue:1 alpha:1];
        node.colorBlendFactor =
            (node.pile == self.selectedPile && node.index >= self.selectedIndex) ? 0.16 : 0;
    }
}
- (void)cancelInteraction {
    self.activeTouch = nil;
    self.dragging = NO;
    self.lifted = nil;
    self.origins = nil;
    self.selectedPile = -1;
    [self showSelection];
}
- (void)changed {
    [self cancelInteraction];
    [self refreshAnimated:YES];
    if (self.gameChanged)
        self.gameChanged();
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.game.won || self.activeTouch)
        return;
    UITouch *touch = touches.anyObject;
    self.activeTouch = touch;
    self.touchStart = [touch locationInNode:self];
    self.dragging = NO;
    CardNode *node = [self cardAt:self.touchStart];
    if (node && [self.game canLiftFrom:node.pile index:node.index]) {
        NSMutableArray *lifted = [NSMutableArray array], *origins = [NSMutableArray array];
        for (NSInteger i = node.index; i < (NSInteger)self.game.piles[node.pile].count; i++) {
            CardNode *n = self.cards[@(self.game.piles[node.pile][i].identifier)];
            [n removeActionForKey:@"move"];
            [lifted addObject:n];
            [origins addObject:[NSValue valueWithCGPoint:n.position]];
        }
        self.lifted = lifted;
        self.origins = origins;
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.activeTouch || ![touches containsObject:self.activeTouch] || !self.lifted.count)
        return;
    CGPoint point = [self.activeTouch locationInNode:self];
    CGFloat dx = point.x - self.touchStart.x, dy = point.y - self.touchStart.y;
    if (!self.dragging && hypot(dx, dy) < 7)
        return;
    self.dragging = YES;
    CardNode *first = self.lifted.firstObject;
    self.selectedPile = first.pile;
    self.selectedIndex = first.index;
    [self showSelection];
    for (NSUInteger i = 0; i < self.lifted.count; i++) {
        CardNode *n = self.lifted[i];
        CGPoint origin = [self.origins[i] CGPointValue];
        n.position = CGPointMake(origin.x + dx, origin.y + dy);
        n.zPosition = 1000 + i;
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.activeTouch || ![touches containsObject:self.activeTouch])
        return;
    UITouch *touch = self.activeTouch;
    CGPoint point = [touch locationInNode:self];
    self.activeTouch = nil;
    NSInteger destination = [self pileAt:point];
    if (self.dragging) {
        [self.game moveFrom:self.selectedPile index:self.selectedIndex to:destination];
        [self changed];
        return;
    }
    self.lifted = nil;
    self.origins = nil;
    if (hypot(point.x - self.touchStart.x, point.y - self.touchStart.y) > 12) {
        [self changed];
        return;
    }
    if (destination == 0) {
        [self.game draw];
        [self changed];
        return;
    }
    CardNode *node = [self cardAt:point];
    if (self.selectedPile >= 0 && [self.game moveFrom:self.selectedPile
                                                index:self.selectedIndex
                                                   to:destination]) {
        [self changed];
        return;
    }
    if (node && [self.game canLiftFrom:node.pile index:node.index]) {
        NSInteger foundation = [self.game foundationFor:node.pile index:node.index];
        if (foundation != NSNotFound && (touch.tapCount >= 2 || self.selectedPile == node.pile)) {
            [self.game moveFrom:node.pile index:node.index to:foundation];
            [self changed];
            return;
        }
        self.selectedPile = node.pile;
        self.selectedIndex = node.index;
    } else
        self.selectedPile = -1;
    [self showSelection];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cancelInteraction];
    [self refreshAnimated:NO];
}
- (void)celebrate {
    if (UIAccessibilityIsReduceMotionEnabled())
        return;
    for (NSInteger p = 2; p < 6; p++) {
        Card *c = self.game.piles[p].lastObject;
        CardNode *n = self.cards[@(c.identifier)];
        [n runAction:[SKAction sequence:@[
               [SKAction waitForDuration:0.2 + (p - 2) * 0.09], [SKAction moveByX:0 y:14 duration:0.18],
               [SKAction moveByX:0 y:-14 duration:0.25]
           ]]
             withKey:@"victory"];
    }
}
@end

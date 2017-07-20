//
//  WZWWaterWaveView.m
//  WZWWaterWaveView
//
//  Created by zhiwei wu on 2017/7/19.
//  Copyright © 2017年 wzw. All rights reserved.
//

#import "WZWWaterWaveView.h"

NSUInteger const WaterWaveWH = 90;
NSString * const GrayImg = @"bag1.png";
NSString * const SinImg = @"bag2.png";
NSString * const CosImg = @"bag3.png";

@interface WZWWaterWaveView () {
    CGFloat waveAmplitude;    // 波纹振幅
    CGFloat waveCycle;        // 波纹周期
    CGFloat waveSpeed;        // 波纹速度
    CGFloat waveGrowth;       //波纹上升速度
    
    CGFloat waterWaveHeight;
    CGFloat waterWaveWidth;
    CGFloat offsetX;           // 波浪x位移
    CGFloat currentWavePointY; // 当前波浪的高度Y
    
    float variable;            // 可变参数，更加真实，模拟波纹
    BOOL increase;             // 增减变化
}

@property (nonatomic, strong) UIView * mainView;
@property (nonatomic, strong) CADisplayLink * waveDisplayLink;
@property (nonatomic, strong) CAShapeLayer * sinShapLayer;
@property (nonatomic, strong) CAShapeLayer * cosShapLayer;
@property (nonatomic, strong) UIImageView * grayImgV;
@property (nonatomic, strong) UIImageView * sinImgV;
@property (nonatomic, strong) UIImageView * cosImgV;

@end

@implementation WZWWaterWaveView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layout];
    }
    return self;
}

#pragma mark - layout

- (void)layout {
    
    [self addSubview:self.mainView];
    
    waterWaveHeight = self.mainView.bounds.size.height / 2.0;
    waterWaveWidth = self.mainView.bounds.size.width;
    
    if (waterWaveWidth > 0) {
        waveCycle = 1.29 * M_PI / waterWaveWidth;
    }
    
    if (currentWavePointY <= 0) {
        currentWavePointY = self.mainView.bounds.size.height;
    }
    
    waterWaveHeight = self.mainView.bounds.size.height / 2.0;
    waterWaveWidth = self.mainView.bounds.size.width;
    waveGrowth = 0.4;
    waveSpeed = 0.35 / M_PI;
    
    [self.mainView addSubview:self.grayImgV];
    [self.mainView addSubview:self.cosImgV];
    [self.mainView addSubview:self.sinImgV];
    
    self.sinImgV.layer.mask = self.sinShapLayer;
    self.cosImgV.layer.mask = self.cosShapLayer;
    
    [self resetProperty];
}

#pragma mark - action

+ (void)show {
    [[self shareWZWWaterWaveView] showView];
}

+ (void)dismiss {
    [[self shareWZWWaterWaveView] stopWave];
}

- (void)showView {
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    self.hidden = NO;
    self.center = [UIApplication sharedApplication].delegate.window.center;
    [self startWave];
}

- (void)startWave {
    
    [self resetProperty];
    
    //启动定时器
    [self.waveDisplayLink invalidate];
    self.waveDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [self.waveDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)getCurrentWave:(CADisplayLink *)displayLink {
    [self animateWave];
    
    if (currentWavePointY > 2 * waterWaveHeight * (1 - 0.9)) {
        //波浪高度未达到指定高度 继续上涨
        currentWavePointY -= waveGrowth;
    }
    
    //波浪位移
    offsetX += waveSpeed;
    
    [self setCurrentSinShapLayer];
    [self setCurrentCosShapLayer];
}

- (void)setCurrentCosShapLayer {
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <= waterWaveWidth; x++) {
        //余弦波浪公式
        y = waveAmplitude * cos(waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.mainView.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.mainView.frame.size.height);
    CGPathCloseSubpath(path);
    
    self.cosShapLayer.path = path;
    CGPathRelease(path);
}

- (void)setCurrentSinShapLayer {
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <= waterWaveWidth; x++) {
        //正弦波浪公式
        y = waveAmplitude * sin(waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.mainView.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.mainView.frame.size.height);
    CGPathCloseSubpath(path);
    
    self.sinShapLayer.path = path;
    CGPathRelease(path);
}

- (void)animateWave {
    if (increase) {
        variable += 0.01;
    } else {
        variable -= 0.01;
    }
    
    if (variable <= 1) {
        increase = YES;
    }
    
    if (variable >= 1.6) {
        increase = NO;
    }
    
    waveAmplitude = variable * 5;
}

- (void)resetProperty {
    currentWavePointY = self.mainView.bounds.size.height;
    variable = 1.6;
    increase = NO;
    offsetX = 0;
}

- (void)stopWave {
    [self.waveDisplayLink invalidate];
    [self.sinShapLayer removeFromSuperlayer];
    self.sinShapLayer = nil;
    [self.cosShapLayer removeFromSuperlayer];
    self.cosShapLayer = nil;
    self.hidden = YES;
}

- (void)dealloc {
    [self reset];
}

- (void)reset {
    [self stopWave];
    [self resetProperty];
    
    [self.sinShapLayer removeFromSuperlayer];
    self.sinShapLayer = nil;
    [self.cosShapLayer removeFromSuperlayer];
    self.cosShapLayer = nil;
}

#pragma mark - Initialization

+ (WZWWaterWaveView *)shareWZWWaterWaveView {
    static WZWWaterWaveView * singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[self alloc] initWithFrame:CGRectMake(0, 0, WaterWaveWH, WaterWaveWH)];
    });
    return singleTon;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WaterWaveWH, WaterWaveWH)];
        _mainView.backgroundColor = [UIColor clearColor];
        _mainView.userInteractionEnabled = YES;
    }
    return _mainView;
}

- (UIImageView *)grayImgV {
    if (!_grayImgV) {
        _grayImgV = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
        _grayImgV.image = [UIImage imageNamed:GrayImg];
        _grayImgV.layer.cornerRadius = WaterWaveWH / 2.0;
        _grayImgV.layer.masksToBounds = YES;
    }
    return _grayImgV;
}

- (UIImageView *)sinImgV {
    if (!_sinImgV) {
        _sinImgV = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
        _sinImgV.image = [UIImage imageNamed:SinImg];
        _sinImgV.layer.cornerRadius = WaterWaveWH / 2.0;
        _sinImgV.layer.masksToBounds = YES;
    }
    return _sinImgV;
}

- (UIImageView *)cosImgV {
    if (!_cosImgV) {
        _cosImgV = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
        _cosImgV.image = [UIImage imageNamed:CosImg];
        _cosImgV.layer.cornerRadius = WaterWaveWH / 2.0;
        _cosImgV.layer.masksToBounds = YES;
    }
    return _cosImgV;
}

- (CAShapeLayer *)sinShapLayer {
    if (!_sinShapLayer) {
        _sinShapLayer = [CAShapeLayer layer];
        _sinShapLayer.backgroundColor = [UIColor clearColor].CGColor;
        _sinShapLayer.fillColor = [UIColor redColor].CGColor;
        _sinShapLayer.frame = CGRectMake(0, 0, self.mainView.bounds.size.width, self.mainView.bounds.size.height);
    }
    return _sinShapLayer;
}

- (CAShapeLayer *)cosShapLayer {
    if (!_cosShapLayer) {
        _cosShapLayer = [CAShapeLayer layer];
        _cosShapLayer.backgroundColor = [UIColor clearColor].CGColor;
        _cosShapLayer.fillColor = [UIColor greenColor].CGColor;
        _cosShapLayer.frame = CGRectMake(0, 0, self.mainView.bounds.size.width, self.mainView.bounds.size.height);
    }
    return _cosShapLayer;
}

@end

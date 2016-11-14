//
//  ViewController.m
//  GLLoveLiveVideo
//
//  Created by ZK on 2016/10/21.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <OpenGLES/EAGL.h>
#import <Endian.h>
#import "UIImage+Extensions.h"
#import <iflyMSC/IFlyFaceSDK.h>

#import "IFlyFaceImage.h"
#import "IFlyFaceResultKeys.h"

#import "CanvasView.h"
#import "CalculatorTools.h"


@interface ViewController () <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageUIElement *element;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) UIView *elementView;
@property (nonatomic, strong) UIImageView *capImageView;
@property (nonatomic, assign) CGRect faceBounds;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, assign) BOOL faceThinking;
@property (nonatomic, strong) UIView *faceView;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) NSMutableArray *capImages;
@property (nonatomic, assign) NSInteger index;

//@property (nonatomic, retain ) IFlyFaceDetector * faceDetector;

@property (nonatomic, strong ) CanvasView  *viewCanvas;

@property (nonatomic, strong) UIImageView *eyeImageView;

@property (nonatomic, strong) NSMutableArray *eyeImages;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if 0
    NSMutableDictionary* videoSettings = [[NSMutableDictionary alloc] init];;
    [videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [videoSettings setObject:[NSNumber numberWithInteger:720] forKey:AVVideoWidthKey];
    [videoSettings setObject:[NSNumber numberWithInteger:1280] forKey:AVVideoHeightKey];
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary* audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
                                   [ NSNumber numberWithFloat: 16000.0 ], AVSampleRateKey,
                                   [ NSData dataWithBytes:&channelLayout length: sizeof( AudioChannelLayout ) ], AVChannelLayoutKey,
                                   [ NSNumber numberWithInt: 32000 ], AVEncoderBitRateKey,
                                   nil];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    unlink([pathToMovie UTF8String]); //如果视频存在，删掉！
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1280, 720) fileType:AVFileTypeMPEG4 outputSettings:videoSettings];
    [self.movieWriter setHasAudioTrack:YES audioSettings:audioSettings];
#endif
    
    //    self.faceDetector=[IFlyFaceDetector sharedInstance];
    //    [self.faceDetector setParameter:@"1" forKey:@"detect"];
    //    [self.faceDetector setParameter:@"1" forKey:@"align"];
    //
    //    self.viewCanvas = [[CanvasView alloc] initWithFrame:self.view.frame] ;
    //    [self.view addSubview:self.viewCanvas] ;
    //    self.viewCanvas.backgroundColor = [UIColor clearColor] ;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    unlink([pathToMovie UTF8String]); //如果视频存在，删掉！
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
    
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    GPUImageBrightnessFilter* brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    //brightnessFilter.brightness = 0.2;
    [self.videoCamera addTarget:brightnessFilter];
    
    self.element = [[GPUImageUIElement alloc] initWithView:self.elementView];
    
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    [brightnessFilter addTarget:blendFilter];
    [self.element addTarget:blendFilter];
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    [blendFilter addTarget:self.filterView];
    [blendFilter addTarget:self.movieWriter];
    
    __weak typeof (self) weakSelf = self;
    [brightnessFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        __strong typeof (self) strongSelf = weakSelf;
        [strongSelf.element update];
    }];
    
    [self.videoCamera startCameraCapture];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.movieWriter startRecording];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.movieWriter finishRecording];
    });
}


- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!_faceThinking) {
        CFAllocatorRef allocator = CFAllocatorGetDefault();
        CMSampleBufferRef sbufCopyOut;
        CMSampleBufferCreateCopy(allocator,sampleBuffer,&sbufCopyOut);
        [self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
    }
    
}

- (void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    _faceThinking = YES;
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    image = [image imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI/2.0)];
    CGPoint origin = [image extent].origin;
    image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];
    
    NSArray *features = [self.faceDetector featuresInImage:image];
    
    CIFaceFeature* faceFeature = features.firstObject;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition) {
            
            CGPoint leftEyePosition =faceFeature.leftEyePosition;
            CGPoint rightEyePosition =faceFeature.rightEyePosition;
            
            CGPoint point = CGPointMake(leftEyePosition.x + (rightEyePosition.x-leftEyePosition.x)/2, leftEyePosition.y + (rightEyePosition.y-leftEyePosition.y)/2);
            
            self.eyeImageView.hidden = NO;
            self.eyeImageView.layer.position =[self verticalFlipFromPoint:point inSize:image.extent.size toSize:self.view.bounds.size];
        }else{
            self.eyeImageView.hidden = YES;
        }
    });
    
    _faceThinking = NO;
    
}


-(CGRect)verticalFlipFromRect:(CGRect)originalRect inSize:(CGSize)originalSize toSize:(CGSize)finalSize{
    CGRect finalRect = originalRect;
    finalRect.origin.y = originalSize.height - finalRect.origin.y - finalRect.size.height;
    CGFloat hRate = finalSize.width / originalSize.width;
    CGFloat vRate = finalSize.height / originalSize.height;
    finalRect.origin.x *= hRate;
    finalRect.origin.y *= vRate;
    finalRect.size.width *= hRate;
    finalRect.size.height *= vRate;
    return finalRect;
    
}

- (CGPoint)verticalFlipFromPoint:(CGPoint)originalPoint inSize:(CGSize)originalSize toSize:(CGSize)finalSize{
    CGPoint finalPoint = originalPoint;
    finalPoint.y = originalSize.height - finalPoint.y;
    CGFloat hRate = finalSize.width / originalSize.width;
    CGFloat vRate = finalSize.height / originalSize.height;
    finalPoint.x *= hRate;
    finalPoint.y *= vRate;
    finalPoint.x = self.view.bounds.size.width - finalPoint.x;
    return finalPoint;
    
}


#if 0
#pragma mark -讯飞人脸识别，但是。。。GPUImage给的流解析不出人脸，技术支持也说没用适配
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    IFlyFaceImage* faceImage=[self faceImageFromSampleBuffer:sampleBuffer];
    [self onOutputFaceImage:faceImage];
    faceImage=nil;
}

- (IFlyFaceImage *) faceImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    
    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *lumaBuffer  = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
    size_t width  = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context=CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace,0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    IFlyFaceDirectionType faceOrientation=[self faceImageOrientation];
    
    IFlyFaceImage* faceImage=[[IFlyFaceImage alloc] init];
    if(!faceImage){
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    
    faceImage.data= (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width=width;
    faceImage.height=height;
    faceImage.direction=faceOrientation;
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    
    
    return faceImage;
    
}

-(IFlyFaceDirectionType)faceImageOrientation{
    
    IFlyFaceDirectionType faceOrientation=IFlyFaceDirectionTypeLeft;
    
    AVCaptureDevicePosition currentCameraPosition = [self.videoCamera cameraPosition];
    BOOL isFrontCamera= currentCameraPosition == AVCaptureDevicePositionBack ;
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortrait:{//
            faceOrientation=IFlyFaceDirectionTypeLeft;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            faceOrientation=IFlyFaceDirectionTypeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeUp:IFlyFaceDirectionTypeDown;
        }
            break;
        default:{//
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeDown:IFlyFaceDirectionTypeUp;
        }
            
            break;
    }
    
    return faceOrientation;
}

-(void)onOutputFaceImage:(IFlyFaceImage*)faceImg{
    
    NSString* strResult=[self.faceDetector trackFrame:faceImg.data withWidth:faceImg.width height:faceImg.height direction:(int)faceImg.direction];
    NSLog(@"result:%@",strResult);
    
    //此处清理图片数据，以防止因为不必要的图片数据的反复传递造成的内存卷积占用。
    faceImg.data=nil;
    
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(praseTrackResult:OrignImage:)];
    if (!sig) return;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:@selector(praseTrackResult:OrignImage:)];
    [invocation setArgument:&strResult atIndex:2];
    [invocation setArgument:&faceImg atIndex:3];
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil  waitUntilDone:NO];
    faceImg=nil;
}

-(void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg{
    
    if(!result){
        return;
    }
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData=nil;
        if(!faceDic){
            return;
        }
        
        NSString* faceRet=[faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray* faceArray=[faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic=nil;
        
        int ret=0;
        if(faceRet){
            ret=[faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count]<1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFace];
            } ) ;
            return;
        }
        
        //检测到人脸
        
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for(id faceInArr in faceArray){
            
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                
                NSDictionary* positionDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString* rectString=[self praseDetect:positionDic OrignImage: faceImg];
                positionDic=nil;
                
                NSDictionary* landmarkDic=[faceInArr objectForKey:KCIFlyFaceResultLandmark];
                NSMutableArray* strPoints=[self praseAlign:landmarkDic OrignImage:faceImg];
                landmarkDic=nil;
                
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }
                
                strPoints=nil;
                
                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson] ;
                
                dicPerson=nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
                } ) ;
            }
        }
        faceArray=nil;
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

- (void) showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons{
    if (self.viewCanvas.hidden) {
        self.viewCanvas.hidden = NO ;
    }
    self.viewCanvas.arrPersons = arrPersons ;
    [self.viewCanvas setNeedsDisplay] ;
}


- (void) hideFace {
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
}

-(NSMutableArray*)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg{
    if(!landmarkDic){
        return nil;
    }
    
    // 判断摄像头方向
    AVCaptureDevicePosition currentCameraPosition = [self.videoCamera cameraPosition];
    BOOL isFrontCamera= currentCameraPosition == AVCaptureDevicePositionBack ;
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.view.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.view.frame.size.height / faceImg.width;
    
    NSMutableArray *arrStrPoints = [NSMutableArray array] ;
    NSEnumerator* keys=[landmarkDic keyEnumerator];
    for(id key in keys){
        id attr=[landmarkDic objectForKey:key];
        if(attr && [attr isKindOfClass:[NSDictionary class]]){
            
            id attr=[landmarkDic objectForKey:key];
            CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y,x);
            
            if(!isFrontCamera){
                p=pSwap(p);
                p=pRotate90(p, faceImg.height, faceImg.width);
            }
            
            p=pScale(p, widthScaleBy, heightScaleBy);
            
            [arrStrPoints addObject:NSStringFromCGPoint(p)];
            
        }
    }
    return arrStrPoints;
    
}


-(NSString*)praseDetect:(NSDictionary* )positionDic OrignImage:(IFlyFaceImage*)faceImg{
    
    if(!positionDic){
        return nil;
    }
    
    
    AVCaptureDevicePosition currentCameraPosition = [self.videoCamera cameraPosition];
    BOOL isFrontCamera= currentCameraPosition == AVCaptureDevicePositionBack ;
    // 判断摄像头方向
    
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.view.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.view.frame.size.height / faceImg.width;
    
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    
    float cx = (left+right)/2;
    float cy = (top + bottom)/2;
    float w = right - left;
    float h = bottom - top;
    
    float ncx = cy ;
    float ncy = cx ;
    
    CGRect rectFace = CGRectMake(ncx-w/2 ,ncy-w/2 , w, h);
    
    if(!isFrontCamera){
        rectFace=rSwap(rectFace);
        rectFace=rRotate90(rectFace, faceImg.height, faceImg.width);
    }
    
    rectFace=rScale(rectFace, widthScaleBy, heightScaleBy);
    
    return NSStringFromCGRect(rectFace);
    
}
#endif

#pragma mark -
#pragma mark Getter

- (CIDetector *)faceDetector {
    if (!_faceDetector) {
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return _faceDetector;
}

- (UIView *)elementView {
    if (!_elementView) {
        _elementView = [[UIView alloc] initWithFrame:self.view.frame];
        
        UIImage* frameImage = [UIImage imageNamed:@"frame_0.png"];
        CGFloat width = self.view.frame.size.height*(frameImage.size.width/frameImage.size.height);
        _capImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-width)/2, 0, width , self.view.frame.size.height)];
        
        _capImages = [NSMutableArray array];
        for (int i = 0; i < 23; i++) {
            NSString *imgName = [NSString stringWithFormat:@"%@%d", @"frame_", i];
            NSString *img_path = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
            UIImage *img = [UIImage imageWithContentsOfFile:img_path];
            [_capImages addObject:img];
        }
        [_elementView addSubview:_capImageView];
        
        
        _eyeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 227, 101)];
        _eyeImageView.hidden=YES;
        _eyeImages = [NSMutableArray array];
        for (int i = 0; i < 23; i++) {
            NSString *imgName = [NSString stringWithFormat:@"%@%d", @"eye_", i];
            NSString *img_path = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
            UIImage *img = [UIImage imageWithContentsOfFile:img_path];
            [_eyeImages addObject:img];
        }
        [_elementView addSubview:_eyeImageView];
        
        
        
        // 定义时钟对象
        CADisplayLink *displayLink  = [CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
        
        // 添加时钟对象到主运行循环
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _elementView;
}

- (void)step
{
    // 定义一个变量记录执行次数
    static int a = 0;
    if (a++ % 6  == 0) {
        UIImage *image = _capImages[_index];
        _capImageView.layer.contents = (id)image.CGImage; // 更新图片
        _index = (_index + 1) % _capImages.count;
        
        UIImage *eyeImage = _eyeImages[_index];
        _eyeImageView.layer.contents = (id)eyeImage.CGImage; // 更新图片
        _index = (_index + 1) % _eyeImages.count;
    }
}



@end

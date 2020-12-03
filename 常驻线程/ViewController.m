//
//  ViewController.m
//  常驻线程
//
//  Created by 李文仲 on 2020/7/2.
//  Copyright © 2020 CLAY. All rights reserved.
//

#import "ViewController.h"
#import "LWZSingleton.h"
#import <objc/runtime.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <Masonry.h>

//#import "UIButton+enlargeHitTest.h"

@interface ViewController ()
@property (nonatomic, strong) NSString *mark;
//@property (atomic, strong) NSString *mark;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, weak) NSString *poolStr;
@property (nonatomic, weak) NSArray *weakArr;
@end

NSString *mutexStr = @"";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self gcdAndThread];
//    [self taggedPointer];
//    [self singletonAndKVO];
//    [self pointer_and_object_test];
//    [self invocation_invoke_test];
    [self btn_hitTest];
//    [self some_stringTest];
//    [self AFN_test];
//    [self sessionAbout];
//    (void)self.masonryAbout;
//    [self operationTest];
//    [self mutexAndSpinLock];
}

- (void)mutexAndSpinLock {
    self.lock = [[NSLock alloc] init];
    [self changeMutexStr:@"1"];
    [self changeMutexStr:@"2"]; //既然被锁住就一直等 oke了就继续执行.
    NSLog(@"mutex: %@",mutexStr);
}

- (void)changeMutexStr:(NSString *)str {
//    @synchronized (self) {
//        sleep(2);
//        NSLog(@"sleep");
//        mutexStr = str;
//    }

    [_lock lock];
    sleep(2);
    NSLog(@"sleep");
    mutexStr = str;
    [_lock unlock];

// 结果都一样.
//    2020-11-16 16:49:07.843502+0800 常驻线程[35935:64284431] sleep
//    2020-11-16 16:49:09.844787+0800 常驻线程[35935:64284431] sleep
//    2020-11-16 16:49:09.845099+0800 常驻线程[35935:64284431] mutex: 2

}



- (void)operationTest {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //default1 -1不限制, 1串行, >1 并行.
    queue.maxConcurrentOperationCount = -1;
    [queue addOperationWithBlock:^{
        NSLog(@"addOperationWithBlock! ");
    }];

    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(btnAction) object:nil];
//    [invocationOperation start];

    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation!");
    }];
//    [blockOperation start];
    [invocationOperation addDependency:blockOperation];
    [queue addOperation:invocationOperation];
    [queue addOperation:blockOperation];

}

- (void)masonryAbout {
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.blueColor;
    [self.view addSubview:view];
    NSArray *constraints = [view mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.height返回NSViewConstraint, make.height.width返回NSCompositeConstraint.
        make.height.width.mas_equalTo(60);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
    NSLog(@"%@",constraints);
//2020-11-13 15:54:52.204099+0800 常驻线程[34274:63261770] (
//    "<MASCompositeConstraint: 0x6000032f0e70>",
//    "<MASViewConstraint: 0x6000018afd80>",
//    "<MASViewConstraint: 0x6000018afde0>"
//)



//    //block是否可以修改形参, 这里本就是引用/指针, 有何不可改.
//    NSMutableString *str = [NSMutableString stringWithString:@"哈"];
//    NSLog(@"%@",str);
//    void (^block)(NSMutableString *) = ^(NSMutableString *s){
//        [s appendString:@"喽"];
//    };
//    block(str);
//    NSLog(@"%@",str);
////    2020-11-12 14:26:40.287432+0800 常驻线程[31372:63019234] 哈
////    2020-11-12 14:26:40.287613+0800 常驻线程[31372:63019234] 哈喽
//    int i = 1;
//    NSLog(@"%i",i);
//    void (^block2)(int a) = ^(int a) {
//        a += 100;
//    };
//    block2(i);
//    NSLog(@"%i",i);
////    2020-11-12 14:31:35.475151+0800 常驻线程[31417:63026675] 1
////    2020-11-12 14:31:35.475245+0800 常驻线程[31417:63026675] 1

}

//网络相关
- (void)sessionAbout {
    //stringByAddingPercentEncodingWithAllowedCharacters 网络请求url编码,只有汉字需要被额外percent编码
    //还原是 [str stringByRemovingPercentEncoding:]
    NSString *str1 = @"233xyz";
    NSString *str2 = @"233xyz哈喽";
    NSLog(@"str1 percent convert = %@",[str1 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
    NSLog(@"str2 percent convert = %@",[str2 stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
//    2020-11-11 14:57:16.612902+0800 常驻线程[28995:62770842] str1 percent convert = 233xyz
//    2020-11-11 14:57:16.613095+0800 常驻线程[28995:62770842] str2 percent convert = 233xyz%E5%93%88%E5%96%BD


    //加载网络图片
    NSString *urlStr = @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3670756122,3973698678&fm=26&gp=0.jpg";
    //imageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 500)];
    imageView.backgroundColor = UIColor.blackColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //NSURLSessionTask的子类之一, dataTask.
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error = %@",error);
        } else {
            //success
            NSLog(@"data = %@",data);
            NSLog(@"thread = %@",NSThread.currentThread);
            dispatch_async(dispatch_get_main_queue(), ^{ //UI刷新必须在主线程
                imageView.image = [UIImage imageWithData:data];
            });
        }
    }];
    //resume
    [dataTask resume];

}

- (void)gcdAndThread {
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadElse) object:nil];
    thread.name = @"my private thread";
    [thread start];

//    常驻线程
//    [NSThread detachNewThreadSelector:@selector(threadElse) toTarget:self withObject:nil]; //detach则不需要start
//
//    [self performSelector:@selector(threadElse) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)singletonAndKVO {
    //单例 signleton
    LWZSingleton *sigleton = [[LWZSingleton alloc] init];
    LWZSingleton *singleton2 = [LWZSingleton shareSingleton]; //地址一样
    NSLog(@"%@\n%@",sigleton,singleton2);
    [LWZSingleton tearDown];
    LWZSingleton *singleton3 = [LWZSingleton shareSingleton]; //新单例出现
    NSLog(@"%@\n%@\n%@",sigleton,singleton2,singleton3);

    //kvo
    LWZSingleton *singleton = [LWZSingleton shareSingleton];
    [singleton addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:@"haha"];
//    singleton.age = 2;

//    //kvo触发唯一条件, 这两个缺一不可
//    [singleton willChangeValueForKey:@"age"];
//    [singleton didChangeValueForKey:@"age"];

//    [singleton performSelector:@selector(changeAge)];

//    [singleton setValue:@123 forKey:@"height"]; //若未调用set方法,只是修改成员变量,不会触发kvo
}

- (void)pointer_and_object_test {
    //对象与指针, 赋值
    NSString *s1 = @"2333";
    NSString *s2 = s1; //赋值操作, s2 s1指针内容一致, 均指向@"2333"这块内存
    s1 = nil; //只是清空s1指针, s2指针依然指向@"2333"这个对象 这块内存数据.
    NSLog(@"s1=%@,\ns2=%@",s1,s2);


    //    //autoreleasepool
    ////    NSString *poolstr = [NSString stringWithFormat:@"poolstr"]; //字符常量区,始终存在
    //    NSString *poolstr = [NSString stringWithFormat:@"poolstrfsdafas"]; //正常字符对象,再堆区. 故runloop之外的DidAppear poolstr对象已经被释放掉; 而WillAppear虽然计数为0 但是他和viewDidLoad在一个runloop还没到beforeWaiting还没被释放
    //    _poolStr = poolstr;

    //    _poolStr = [NSString stringWithFormat:@"poolstrfsdafas"];
    //    NSLog(@"load --- %@",_poolStr);

    //    @autoreleasepool { //里面的对象内存会在}后直接计算并决定释放
    //        NSString *poolstr = [NSString stringWithFormat:@"poolstrfsdafas"];
    //        _poolStr = poolstr;
    //    }
    //
    //    NSLog(@"load --- %@",_poolStr); //null 都是null

    //非autorelease对象 出}直接销毁了,因为和autoreleasePool无关,故也和runloop无关
    NSArray *weakArr = [[NSArray alloc] initWithObjects:@"haha", nil];
    _weakArr= weakArr;
    NSLog(@"_weakArr= %@",_weakArr);

    //    NSString *s1 = [NSString stringWithFormat:@"1"]; //NSTaggedPointerString
    //    NSString *s2 = [NSString stringWithFormat:@"poolstr"]; //NSTaggedPointerString
    //    NSString *s3 = [NSString stringWithFormat:@"1sadfadsfsfsdfds"]; //__NSCFString
    //    NSLog(@"%@\n%@\n%@",s1,s2,s3);
}

- (void)invocation_invoke_test {
    //invocation invoke
    NSString *str = @"我的调用";
    NSMethodSignature *signature = [ViewController instanceMethodSignatureForSelector:@selector(wz_nslog:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//    invocation.target = self;
    invocation.selector = @selector(wz_nslog:);
    [invocation setArgument:&str atIndex:2];
    [invocation invokeWithTarget:self];

    //消息转发 _msg_forwarding
    [self performSelector:@selector(foo)];
}

- (void)decimal_number {
    //防止精度丢失
    NSString *num = @"1";
    NSLog(@"%li",num.integerValue);
    NSLog(@"%lf",num.floatValue);
    NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:num];
    NSLog(@"%lf",decimalNum.floatValue);
}

- (void)btn_hitTest {
    //uiview
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.blueColor;
    view.frame = CGRectMake(20, 20, 300, 300);
    [self.view addSubview:view];

    //UIButton+enlargeHitTest 扩大按钮点击范围
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.userInteractionEnabled = NO;
    [btn setBackgroundImage:[UIImage imageNamed:@"IMG_4989"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 50, 80);
    [view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [btn setEnlargeEdge:50];
//    btn.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"ffdasfsafasfasfafdsfaasdssef"];
}

- (void)some_stringTest {

//    NSLog(@"\\"); //转义字符\
//    NSNumber *num1 = [[NSNumber alloc] initWithInt:1];
//    NSNumber *num2 = @2;
//    NSNumber *num3 = [NSNumber numberWithInt:1];
//    NSString *s1 = @"1";
//    NSString *s2 = [NSString stringWithFormat:@"%li",12];
}


- (void)AFN_test {
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
         AFNetworkReachabilityStatusUnknown          = -1,
         AFNetworkReachabilityStatusNotReachable     = 0,
         AFNetworkReachabilityStatusReachableViaWWAN = 1,
         AFNetworkReachabilityStatusReachableViaWiFi = 2,
     };

     */
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络~");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络~");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"使用数据网络~");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"使用wifi~");
                break;
            default:
                break;
        }
    }];
    //开始监控
    [reachabilityManager startMonitoring];


    //AFN
    NSString *urlStr = @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3670756122,3973698678&fm=26&gp=0.jpg";
    //imageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 500)];
    imageView.backgroundColor = UIColor.blackColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView setImageWithURL:[NSURL URLWithString:urlStr]]; //相比httpManager一步就可以.


    //manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"image/jpeg", nil];
    [manager GET:urlStr parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"progress = %@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"response = %@\nresponseObject = %@",task, responseObject);
        NSLog(@"thread: %@",NSThread.currentThread);
        imageView.image = [UIImage imageWithData:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
}

- (void)btnAction {
    NSLog(@"btnAction!!!");
}

//消息转发 _msg_forwarding
+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(foo)) {
//        class_addMethod(self, @selector(foo), msg_forwarding, "v@:"); // v-void   @-self   :-_cmd
//        return YES;
//    }
//    class_replaceMethod(<#Class  _Nullable __unsafe_unretained cls#>, <#SEL  _Nonnull name#>, <#IMP  _Nonnull imp#>, <#const char * _Nullable types#>)
    return [super resolveInstanceMethod:sel];
}

//把消息receiver移交给其他对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return  [super forwardingTargetForSelector:aSelector];
}

//只要返回了 NSMethodSignature, 这个方法就不会崩溃了, 即使之后不再处理.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (aSelector == @selector(foo)) {
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        return signature;
    }
    return [super methodSignatureForSelector:aSelector];
}

//这里已经不会崩溃了, 可以根据情况自由发挥了.
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (anInvocation.selector == @selector(foo)) {
        anInvocation.selector = @selector(invocationSel);
        [anInvocation invoke];
//        [anInvocation invokeWithTarget:self];
        //甚至创造一个全新invocation, 或者直接调用其他方法都可...
    }

}

void msg_forwarding() {
    NSLog(@"消息转发 +resolveInstanceMethod; ");
}

- (void)invocationSel {
    NSLog(@"消息转发 invoke other invocation;");
}



- (void)wz_nslog:(NSString *)str {
    NSLog(@"invoke log ==> %@",str);
}

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSLog(@"%@, %@,%@",keyPath,change,context);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"WillAppear --- %@",_poolStr);
//    NSLog(@"WillAppear --- %@",_weakArr);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"DidAppear --- %@",_poolStr);
//    NSLog(@"WillAppear --- %@",_weakArr);
}


- (void)threadElse {
//    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"timer 1");
    }];
    [[NSRunLoop currentRunLoop] run];
    NSLog(@"after");
}


//崩溃原因是,属性nonatomic, 然后被release的原指针 同时其再次被另一个线程release,即野指针调用的崩溃.(也不是100%崩溃)
- (void)taggedPointer {
    NSString *str1 = [NSString stringWithFormat:@"%d",0];
    NSString *str2 = @"0";
    NSLog(@"%s\n%s",object_getClassName(str1),object_getClassName(str2));
    
    dispatch_queue_t queue = dispatch_queue_create("concurrent mark", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<1000000; i++) {
        dispatch_async(queue, ^{ //改成sync或者后面再执行NSLog都不会导致并发的崩溃.
//            self.mark = [NSString stringWithFormat:@"ksddkjalksdfafsdfadfassdfsadasdjd%d",i];
            self.mark = [NSString stringWithFormat:@"%d",i];
        });
//        NSLog(@"%d",i);
    }
}


@end

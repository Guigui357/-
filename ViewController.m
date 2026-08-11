#import <UIKit/UIKit.h>
#import "ViewController.h"

extern int run_jailbreak(void);

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    [self.jailbreakButton addTarget:weakSelf
                             action:@selector(startJailbreak)
                   forControlEvents:UIControlEventTouchUpInside];
}

- (void)startJailbreak {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf appendLog:@"[+] Starting jailbreak..."];
        int result = run_jailbreak();
        if (result == 0) {
            [weakSelf appendLog:@"[+] Jailbreak succeeded! Respringing..."];
        } else {
            [weakSelf appendLog:@"[!] Jailbreak failed with code %d", result];
        }
    });
}

- (void)appendLog:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.logTextView.text = [weakSelf.logTextView.text stringByAppendingFormat:@"\n%@", msg];
    });
}

@end

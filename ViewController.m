#import <mach/mach.h>

// Declare the C entry point from exploit.c
int run_jailbreak(void);

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *jailbreakButton;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startJailbreak {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self appendLog:@"[+] Starting jailbreak..."];
        int result = run_jailbreak();
        if (result == 0) {
            [self appendLog:@"[+] Jailbreak succeeded! Respringing..."];
        } else {
            [self appendLog:@"[!] Jailbreak failed with code %d", result];
        }
    });
}

- (void)appendLog:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"\n%@", msg];
    });
}
@end

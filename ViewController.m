#import "ViewController.h"
#import "exploit.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *jailbreakButton;
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL isRunning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Jailbreak";
    self.isRunning = NO;
    
    [self setupUI];
}

- (void)setupUI {
    // ----- Log TextView -----
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logTextView.editable = NO;
    self.logTextView.selectable = NO;
    self.logTextView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    self.logTextView.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    self.logTextView.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:12];
    self.logTextView.layer.cornerRadius = 12;
    self.logTextView.layer.masksToBounds = YES;
    self.logTextView.text = @"Aguardando início...\n";
    self.logTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:self.logTextView];
    
    // ----- Jailbreak Button -----
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.jailbreakButton setTitle:@"🚀 Iniciar Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.jailbreakButton setBackgroundColor:[UIColor systemBlueColor]];
    self.jailbreakButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.jailbreakButton.layer.cornerRadius = 14;
    self.jailbreakButton.layer.masksToBounds = YES;
    [self.jailbreakButton addTarget:self
                             action:@selector(startJailbreak)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
    
    // ----- Activity Indicator -----
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.color = [UIColor systemBlueColor];
    [self.view addSubview:self.activityIndicator];
    
    // ----- Constraints -----
    [NSLayoutConstraint activateConstraints:@[
        // Log TextView
        [self.logTextView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.logTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.logTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.logTextView.heightAnchor constraintEqualToConstant:400],
        
        // Jailbreak Button
        [self.jailbreakButton.topAnchor constraintEqualToAnchor:self.logTextView.bottomAnchor constant:30],
        [self.jailbreakButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.jailbreakButton.widthAnchor constraintEqualToConstant:220],
        [self.jailbreakButton.heightAnchor constraintEqualToConstant:55],
        
        // Activity Indicator
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.jailbreakButton.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.jailbreakButton.centerYAnchor],
    ]];
}

- (void)startJailbreak {
    if (self.isRunning) return;
    self.isRunning = YES;
    
    [self.jailbreakButton setEnabled:NO];
    [self.jailbreakButton setTitle:@"" forState:UIControlStateNormal];
    [self.activityIndicator startAnimating];
    [self appendLog:@"═══════════════════════════════"];
    [self appendLog:@"[+] Iniciando jailbreak..."];
    [self appendLog:@"[+] Dispositivo: %@", [UIDevice currentDevice].model];
    [self appendLog:@"[+] iOS: %@", [UIDevice currentDevice].systemVersion];
    [self appendLog:@"═══════════════════════════════"];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int result = run_jailbreak();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.jailbreakButton setEnabled:YES];
            
            if (result == 0) {
                [weakSelf.jailbreakButton setTitle:@"✅ Jailbreak OK!" forState:UIControlStateNormal];
                [weakSelf.jailbreakButton setBackgroundColor:[UIColor systemGreenColor]];
                [weakSelf appendLog:@"═══════════════════════════════"];
                [weakSelf appendLog:@"[+] ✅ Jailbreak concluído com sucesso!"];
                [weakSelf appendLog:@"[+] 🎉 Dispositivo jailbroken!"];
                [weakSelf appendLog:@"[+] SSH: root@localhost -p 2222"];
                [weakSelf appendLog:@"[+] 📱 SpringBoard reiniciando..."];
                [weakSelf appendLog:@"═══════════════════════════════"];
            } else {
                [weakSelf.jailbreakButton setTitle:@"❌ Falhou" forState:UIControlStateNormal];
                [weakSelf.jailbreakButton setBackgroundColor:[UIColor systemRedColor]];
                [weakSelf appendLog:@"═══════════════════════════════"];
                [weakSelf appendLog:@"[!] ❌ Jailbreak falhou com código: %d", result];
                [weakSelf appendLog:@"[!] Verifique logs acima para detalhes"];
                [weakSelf appendLog:@"[!] Dispositivo NÃO está jailbroken"];
                [weakSelf appendLog:@"═══════════════════════════════"];
            }
            
            weakSelf.isRunning = NO;
        });
    });
}

- (void)appendLog:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentText = weakSelf.logTextView.text;
        if (currentText.length > 0) {
            weakSelf.logTextView.text = [currentText stringByAppendingFormat:@"\n%@", msg];
        } else {
            weakSelf.logTextView.text = msg;
        }
        // Scroll para o final
        NSRange range = NSMakeRange(weakSelf.logTextView.text.length - 1, 1);
        [weakSelf.logTextView scrollRangeToVisible:range];
    });
}

@end

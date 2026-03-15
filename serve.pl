use strict;
use IO::Socket::INET;

my $port = 7777;
my $root = 'C:/Users/valer/Downloads/App-Gith';

my $srv = IO::Socket::INET->new(
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 50,
    ReuseAddr => 1,
) or die "Cannot listen on port $port: $!\n";

$srv->blocking(1);
print "Server at: http://localhost:$port/\n";
$|=1;

while (1) {
    my $client = $srv->accept or next;
    $client->autoflush(1);

    # Read request headers
    my $req = '';
    eval {
        local $SIG{ALRM} = sub { die "timeout\n" };
        alarm(5);
        while (defined(my $line = <$client>)) {
            $req .= $line;
            last if $line eq "\r\n" || $line eq "\n";
        }
        alarm(0);
    };
    next if $@;

    my ($method, $path) = $req =~ /^([A-Z]+)\s+(\S+)/;
    $path //= '/';
    $path = '/converter.html' if $path eq '/';
    $path =~ s{^/}{};
    $path =~ s{\.\.}{}g;

    my $file = "$root/$path";

    if (-f $file) {
        my $ct = $file =~ /\.html$/i ? 'text/html; charset=utf-8'
               : $file =~ /\.js$/i   ? 'application/javascript'
               : $file =~ /\.css$/i  ? 'text/css'
               : 'application/octet-stream';

        open my $fh, '<:raw', $file or do {
            print $client "HTTP/1.1 500 Error\r\nContent-Length: 5\r\nConnection: close\r\n\r\nError";
            close $client; next;
        };
        local $/; my $body = <$fh>; close $fh;
        my $len = length($body);

        print $client "HTTP/1.1 200 OK\r\n"
                    . "Content-Type: $ct\r\n"
                    . "Content-Length: $len\r\n"
                    . "Cache-Control: no-cache\r\n"
                    . "Access-Control-Allow-Origin: *\r\n"
                    . "Connection: close\r\n\r\n"
                    . $body;
        print "200 /$path ($len b)\n";
    } else {
        my $b = "Not found: $path";
        print $client "HTTP/1.1 404 Not Found\r\n"
                    . "Content-Length: " . length($b) . "\r\n"
                    . "Connection: close\r\n\r\n" . $b;
        print "404 /$path\n";
    }
    close $client;
}

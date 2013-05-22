var net = require('net');

var port = 8080;

net.createServer(function(sock) {
    
    console.log('Connected: ' + sock.remoteAddress +':'+ sock.remotePort);
    
    sock.on('data', function(data) {
        sock.write(data);
    });
    
    sock.on('close', function(data) {
        console.log('Closed: ' + sock.remoteAddress +' '+ sock.remotePort);
    });
    
}).listen(port);

console.log('Server listening on ' + port);
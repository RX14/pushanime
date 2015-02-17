var url = require("url");
var http = require("http");

exports.handler = function(event, context) {

    console.log("DATA:");
    console.log(event.body);

    var count = 0;
    var num = event.handlers.length;

    event.handlers.forEach(function(handler) {
        var thisURL = url.parse(handler.url);

        var options = {
            hostname: thisURL.hostname,
            port: thisURL.port || 80,
            path: thisURL.path,
            method: handler.method,
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': event.body.length
            }
        };

        var req = http.request(options);

        req.on('finish', function() {
            count++;
            console.log('DONE: ' + JSON.stringify(handler) + " (" + count + "/" + num + ")");

            if (count == num) {
                console.log("EXITING");
                context.done();
            }
        });

        req.write(event.body);
        req.end();
    });
};
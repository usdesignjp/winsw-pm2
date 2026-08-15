'use strict';

// The HTTP server for the walkthrough
const [ , , port = 80, host = '0.0.0.0'] = process.argv;
// [HTTP](https://nodejs.org/docs/latest/api/http.html)
const http = require('node:http');
// Start the HTTP server listening for connections.
const server = http.createServer((req, res) => {
	res.setHeader('Content-Type', 'text/plain');
	res.end('Hello, World!\r\n');
}).listen(port, host, () => {
	console.log(`listening on ${host}:${port}`);
});
// Shutdown gracefully.
process.on('SIGINT', () => {
	console.log('closing all connections...');
	server.close(() => {
		console.log(`${host}:${port} closed`);
		setTimeout(() => {
			process.exit(0);
		});
	});
});
process.on('message', message => {
	console.log(message);
	switch (message) {
	case 'shutdown':
		process.emit('SIGINT', 'SIGINT');
		break;
	default:
		break;
	}
});

const { createProxyMiddleware } = require('http-proxy-middleware');
const http = require('http');
const keepAliveAgent = new http.Agent({ keepAlive: true });

const options = {
  target: 'http://localhost:8080',
  changeOrigin: true,
  ws: true,
  logLevel: 'debug',
  agent: keepAliveAgent,
  headers: {
    'Cache-Control': "no-transform",
  }
}

module.exports = function(app) {
  app.use('/', createProxyMiddleware([
    '/~',
    '/spider',
    '/session.js',
    '/apps/studio/desk.js',
  ], options));
};

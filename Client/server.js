var stitch  = require('stitch'),
    filters = require('swig/lib/filters'),
    fs      = require('fs'),
    express = require('express');

var pkg = stitch.createPackage({
  paths: [__dirname + '/lib', __dirname + '/vendor']
});

var app = express();

var files = fs.readdirSync('view');

files.forEach(function(file){
  console.log('compiling ' + file );

  var src = fs.readFileSync('view/' + file ),
    src  = (src+'').replace(/\n/, '\n'),
    data = 'module.exports = function(swig){ return swig.compile("' + filters.escape( src, 'js' ) + '") }',
    target = file.replace('.html', '.swig');


  fs.writeFileSync( 'lib/view/' + target, data, 'utf8' )
});

//var ;
//var path = require('path');
//var uglify = require('uglify-js');
//
//module.exports = function (bundle) {
//    bundle.register('.html', function (body, file) {
//        return "module.exports = function (swig) {return swig.compile('" + filters.escape(body, 'js') + "', {'filename': '" + filters.escape(path.relative('./templates/', file), 'js') + "'})};";
//    });
//    if (process.env.NODE_ENV === 'production') {
//        bundle.register('post', function (body) {
//            return uglify.minify(body, {
//                'fromString': true
//            }).code;
//        });
//    }
//    bundle.require('jquery-browserify', {'target': 'jquery' });
//};

app.use(express.static('public'));
app.get('/public/app.js', pkg.createServer());

app.listen(3232);
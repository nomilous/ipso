// Generated by CoffeeScript 1.6.3
var EOL, basename, dirname, join, mkdirp, normalize, relative, sep, specLocation, writeFileSync, _ref;

require('colors');

EOL = require('os').EOL;

_ref = require('path'), normalize = _ref.normalize, dirname = _ref.dirname, basename = _ref.basename, relative = _ref.relative, join = _ref.join, sep = _ref.sep;

mkdirp = require('mkdirp');

writeFileSync = require('fs').writeFileSync;

module.exports.specLocation = specLocation = function() {
  var baseName, fileName, line, lineNrs, m, path, specPath, _i, _len, _ref1, _ref2, _ref3;
  _ref1 = (new Error).stack.split(EOL);
  for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
    line = _ref1[_i];
    baseName = void 0;
    try {
      _ref2 = line.match(/.*\((.*?):(.*)/), m = _ref2[0], path = _ref2[1], lineNrs = _ref2[2];
    } catch (_error) {}
    if (path == null) {
      continue;
    }
    fileName = basename(path);
    try {
      _ref3 = fileName.match(/(.*)_spec.[coffee|js]/), m = _ref3[0], baseName = _ref3[1];
    } catch (_error) {}
    if (!baseName) {
      continue;
    }
    specPath = relative(process.cwd(), dirname(path));
    return {
      fileName: fileName,
      baseName: baseName,
      specPath: specPath
    };
  }
};

module.exports.load = function(templatePath) {
  return require(templatePath);
};

module.exports.save = function(templateName, name, does) {
  return does.get({
    query: {
      tag: name
    }
  }, function(err, entity) {
    var error, fileName, moduleBody, pathParts, sourceFile, templateModule, templateModulePath;
    if (err != null) {
      console.log('ipso:', "could not save '" + name + "' - " + err.message);
      return;
    }
    try {
      templateModulePath = join(process.env.HOME, '.ipso', 'templates', templateName);
      templateModule = module.exports.load(templateModulePath);
    } catch (_error) {
      error = _error;
      console.log(error.message.red);
      return;
    }
    specLocation = module.exports.specLocation();
    pathParts = specLocation.specPath.split(sep);
    pathParts.shift();
    pathParts.unshift(process.env.IPSO_SRC || 'src');
    sourceFile = {
      path: process.cwd() + sep + pathParts.join(sep),
      filename: specLocation.baseName + '.coffee'
    };
    if (typeof templateModule.target === 'function') {
      templateModule.target(sourceFile, specLocation);
    }
    if (typeof templateModule.render === 'function') {
      moduleBody = templateModule.render(entity);
    }
    if (typeof moduleBody === 'string') {
      mkdirp.sync(sourceFile.path);
      fileName = join(sourceFile.path, sourceFile.filename);
      writeFileSync(fileName, moduleBody);
      console.log('ipso:', ("Created " + fileName).green);
      return console.log(moduleBody);
    }
  });
};
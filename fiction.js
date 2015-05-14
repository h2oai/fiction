// Generated by CoffeeScript 1.9.1
var OutlineNode, fiction, htmlparser, marked, maskMathJax, parseOutline, toHtml, unmaskMathJax;

marked = require('marked');

htmlparser = require('htmlparser2');

marked.setOptions({
  smartypants: true
});

OutlineNode = (function() {
  function OutlineNode(title, content, children) {
    this.title = title;
    this.content = content != null ? content : '';
    this.children = children != null ? children : [];
  }

  return OutlineNode;

})();

parseOutline = function(html) {
  var _content, _inHeading, _level, _node, _title, outline, parser;
  _level = 0;
  _inHeading = false;
  _title = '';
  _node = null;
  _content = '';
  outline = [new OutlineNode('')];
  parser = new htmlparser.Parser({
    onopentag: function(name, attrs) {
      var attributes, k, pairs, v;
      switch (name) {
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          _inHeading = true;
          _title = '';
          if (_content && _node) {
            _node.content = _content;
          }
          _content = '';
          break;
        default:
          pairs = (function() {
            var results;
            results = [];
            for (k in attrs) {
              v = attrs[k];
              results.push(k + "=\"" + v + "\"");
            }
            return results;
          })();
          attributes = pairs.length ? ' ' + pairs.join(' ') : '';
          _content += "<" + name + attributes + ">";
      }
    },
    ontext: function(text) {
      if (_inHeading) {
        _title += text;
      } else {
        _content += text;
      }
    },
    onclosetag: function(name) {
      var level;
      switch (name) {
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          level = parseInt(name[1], 10);
          if (1 < level - _level) {
            throw new Error("Invalid nesting detected at heading " + level + ": " + _title);
          }
          _level = level;
          outline[_level - 1].children.push(outline[_level] = _node = new OutlineNode(_title));
          _inHeading = false;
          break;
        default:
          _content += "</" + name + ">";
      }
    }
  });
  parser.write(html);
  parser.end();
  if (_content && _node) {
    _node.content = _content;
  }
  return outline[0].children;
};

maskMathJax = function(markdown) {
  var masked, tokenCounter, tokens;
  tokens = {};
  tokenCounter = 0;
  masked = markdown.replace(/\\\((.+?)\\\)/g, function(match, expr) {
    var token;
    token = "xMATHJAXx" + (tokenCounter++);
    tokens[token] = expr;
    return token;
  });
  return [tokens, masked];
};

unmaskMathJax = function(tokens, html) {
  var expr, html_, token;
  html_ = html;
  for (token in tokens) {
    expr = tokens[token];
    html_ = html_.replace(token, "\\(" + expr + "\\)");
  }
  return html_;
};

toHtml = function(markdown) {
  var masked, ref, tokens;
  ref = maskMathJax(markdown), tokens = ref[0], masked = ref[1];
  return unmaskMathJax(tokens, marked(masked));
};

fiction = function(markdown) {
  var html, outline;
  html = toHtml(markdown);
  return outline = parseOutline(html);
};

module.exports = fiction;

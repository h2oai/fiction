marked = require 'marked'
htmlparser = require 'htmlparser2'

marked.setOptions smartypants: yes

class OutlineNode
  constructor: (@title, @content='', @children=[]) ->

parseOutline = (html) ->
  _level = 0
  _inHeading = no
  _title = ''
  _node = null
  _content = ''
  outline = [ new OutlineNode '' ]

  parser = new htmlparser.Parser
    onopentag: (name, attrs) ->
      switch name
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          _inHeading = yes
          _title = ''
          _node.content = _content if _content and _node
          _content = ''
        else
          pairs = for k, v of attrs
            "#{k}=\"#{v}\""
          attributes = if pairs.length
            ' ' + pairs.join ' '
          else 
            ''
          _content += "<#{name}#{attributes}>"
      return

    ontext: (text) ->
      if _inHeading
        _title += text
      else
        _content += text
      return
      
    onclosetag: (name) ->
      switch name
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          level = parseInt name[1], 10

          if 1 < level - _level
            throw new Error "Invalid nesting detected at heading #{level}: #{_title}"

          _level = level
          outline[_level - 1].children.push outline[_level] = _node = new OutlineNode _title
          _inHeading = no
        else
          _content += "</#{name}>"
      return

  parser.write html
  parser.end()
  _node.content = _content if _content and _node # last chunk 
  outline[0].children

maskMathJax = (markdown) ->
  tokens = {}
  tokenCounter = 0
  masked = markdown.replace /\\\((.+?)\\\)/g, (match, expr) ->
    token = "xMATHJAXx#{tokenCounter++}"
    tokens[token] = expr
    token
  [ tokens, masked ]

unmaskMathJax = (tokens, html) ->
  html_ = html
  for token, expr of tokens
    html_ = html_.replace token, "\\(#{expr}\\)"
  html_

toHtml = (markdown) ->
  [ tokens, masked ] = maskMathJax markdown
  unmaskMathJax tokens, marked masked

fiction = (markdown) ->
  html = toHtml markdown
  outline = parseOutline html

module.exports = fiction

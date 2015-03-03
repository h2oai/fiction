marked = require 'marked'
htmlparser = require 'htmlparser2'

marked.setOptions smartypants: yes

createNode = (title) -> title: title, children: []

fiction = (markdown) ->
  _level = 0
  _depth = 0
  _hierarchy = [ createNode '' ]
  _inHeading = no
  _text = ''

  parser = new htmlparser.Parser
    onopentag: (name, attrs) ->
      switch name
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          _inHeading = yes
          _text = ''
      return

    ontext: (text) ->
      if _inHeading
        _text += text
      return
      
    onclosetag: (name) ->
      switch name
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          level = parseInt name[1], 10
          if level < _level
            _depth -= (_level - level)
            _level = level
          else if level > _level
            if 1 isnt level - _level
              throw new Error "Invalid nesting detected at heading #{level}: #{_text}"
            _depth++
            _level = level

          _hierarchy[_depth - 1].children.push _hierarchy[_depth] = createNode _text

          _inHeading = no
      return

  parser.write marked markdown
  parser.end()
  _hierarchy[0].children

module.exports = fiction

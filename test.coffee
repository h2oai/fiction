test = require 'tape'
fiction = require './fiction.js'

test 'fails when child headings are more than one level deep', (t) ->
  t.plan 1
  t.throws ->
    input = '''
    # heading 1
    content 1
    ## heading 1.1
    content 1.1
    #### heading 1.1.1.1
    content 1.1.1.1
    '''
    fiction input

test 'escapes mathjax entries', (t) ->
  t.plan 1

  input = '''
  # Heading 1
  This is some \\(p_{k}(x)=\frac{e^{f_{k}(x)}}{\sum_{l=1}^{K}e^{f_{l}(x)}},\:k=1,2,…,K\\) expression and here is another one: \\(f_{k0} = 0,\: k=1,2,…,K\\).
  '''

  expected = [
    title: 'Heading 1'
    content: '\n<p>This is some \\(p_{k}(x)=\frac{e^{f_{k}(x)}}{\sum_{l=1}^{K}e^{f_{l}(x)}},\:k=1,2,…,K\\) expression and here is another one: \\(f_{k0} = 0,\: k=1,2,…,K\\).</p>\n'
    children: []
  ]

  actual = fiction input
  t.deepLooseEqual actual, expected

test 'converts markdown to outline', (t) ->
  t.plan 1

  input = '''
  # Heading 1
  Content [1](http://go.to/1).
  ## Heading 1.1
  Content [1.1](http://go.to/1.1).
  ### Heading 1.1.1
  Content [1.1.1](http://go.to/1.1.1).
  #### Heading 1.1.1.1
  Content [1.1.1.1](http://go.to/1.1.1.1).
  ##### Heading 1.1.1.1.1
  Content [1.1.1.1.1](http://go.to/1.1.1.1.1).
  ###### Heading 1.1.1.1.1.1
  Content [1.1.1.1.1.1](http://go.to/1.1.1.1.1.1).
  #### Heading 1.1.1.2
  Content [1.1.1.2](http://go.to/1.1.1.2).
  ##### Heading 1.1.1.2.1
  Content [1.1.1.2.1](http://go.to/1.1.1.2.1).
  ###### Heading 1.1.1.2.1.1
  Content [1.1.1.2.1.1](http://go.to/1.1.1.2.1.1).
  '''

  expected = [
    title: 'Heading 1'
    content: '\n<p>Content <a href="http://go.to/1">1</a>.</p>\n'
    children: [
      title: 'Heading 1.1'
      content: '\n<p>Content <a href="http://go.to/1.1">1.1</a>.</p>\n'
      children: [
        title: 'Heading 1.1.1'
        content: '\n<p>Content <a href="http://go.to/1.1.1">1.1.1</a>.</p>\n'
        children: [
          title: 'Heading 1.1.1.1'
          content: '\n<p>Content <a href="http://go.to/1.1.1.1">1.1.1.1</a>.</p>\n'
          children: [
            title: 'Heading 1.1.1.1.1'
            content: '\n<p>Content <a href="http://go.to/1.1.1.1.1">1.1.1.1.1</a>.</p>\n'
            children: [
              title: 'Heading 1.1.1.1.1.1'
              content: '\n<p>Content <a href="http://go.to/1.1.1.1.1.1">1.1.1.1.1.1</a>.</p>\n'
              children: []
            ]
          ]
        ,
          title: 'Heading 1.1.1.2'
          content: '\n<p>Content <a href="http://go.to/1.1.1.2">1.1.1.2</a>.</p>\n'
          children: [
            title: 'Heading 1.1.1.2.1'
            content: '\n<p>Content <a href="http://go.to/1.1.1.2.1">1.1.1.2.1</a>.</p>\n'
            children: [
              title: 'Heading 1.1.1.2.1.1'
              content: '\n<p>Content <a href="http://go.to/1.1.1.2.1.1">1.1.1.2.1.1</a>.</p>\n'
              children: []
            ]
          ]
        ]
      ]
    ]
  ]

  actual = fiction input
  t.deepLooseEqual actual, expected


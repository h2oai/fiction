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

test 'converts markdown to outline', (t) ->
  t.plan 1

  input = '''
  # heading 1
  content 1
  ## heading 1.1
  content 1.1
  ### heading 1.1.1
  content 1.1.1
  #### heading 1.1.1.1
  content 1.1.1.1
  ##### heading 1.1.1.1.1
  content 1.1.1.1.1
  ###### heading 1.1.1.1.1.1
  content 1.1.1.1.1.1
  #### heading 1.1.1.2
  content 1.1.1.2
  ##### heading 1.1.1.2.1
  content 1.1.1.2.1
  ###### heading 1.1.1.2.1.1
  content 1.1.1.2.1.1
  '''

  expected = [
    title: 'heading 1'
    children: [
      title: 'heading 1.1'
      children: [
        title: 'heading 1.1.1'
        children: [
          title: 'heading 1.1.1.1'
          children: [
            title: 'heading 1.1.1.1.1'
            children: [
              title: 'heading 1.1.1.1.1.1'
              children: []
            ]
          ]
        ,
          title: 'heading 1.1.1.2'
          children: [
            title: 'heading 1.1.1.2.1'
            children: [
              title: 'heading 1.1.1.2.1.1'
              children: []
            ]
          ]
        ]
      ]
    ]
  ]

  actual = fiction input
  #console.log JSON.stringify expected, null, 2
  #console.log JSON.stringify actual, null, 2
  t.deepLooseEqual actual, expected


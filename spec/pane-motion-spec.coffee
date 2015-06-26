helpers = require './spec-helper'
{$, View}  = require 'atom-space-pen-views'
_ = require 'underscore-plus'

describe "pane motions", ->
  [editor, editorElement, vimState] = []
  
  beforeEach ->
    vimMode = atom.packages.loadPackage('vim-mode')
    vimMode.activateResources()

    helpers.getEditorElement (element) ->
      editorElement = element
      editor = editorElement.getModel()
      vimState = editorElement.vimState
      vimState.activateCommandMode()
      vimState.resetCommandMode()

  keydown = (key, options={}) ->
    options.element ?= editorElement
    helpers.keydown(key, options)

  describe "the ctrl-^ keybinding", ->
    [pane, recentEditor, item1, item2] = []

    # this class is copied from http://github.com/atom/tabs/blob/master/spec/tabs-spec.coffee
    class TestView extends View
      @deserialize: ({title, longTitle, iconName}) -> new TestView(title, longTitle, iconName)
      @content: (title) -> @div title
      initialize: (@title, @longTitle, @iconName) ->
      getTitle: -> @title
      getLongTitle: -> @longTitle
      getIconName: -> @iconName
      serialize: -> {deserializer: 'TestView', @title, @longTitle, @iconName}
      onDidChangeTitle: (callback) ->
        @titleCallbacks ?= []
        @titleCallbacks.push(callback)
        dispose: => _.remove(@titleCallbacks, callback)
      emitTitleChanged: ->
        callback() for callback in @titleCallbacks ? []
      onDidChangeIcon: (callback) ->
        @iconCallbacks ?= []
        @iconCallbacks.push(callback)
        dispose: => _.remove(@iconCallbacks, callback)
      emitIconChanged: ->
        callback() for callback in @iconCallbacks ? []
      onDidChangeModified: -> # to suppress deprecation warning
        dispose: ->

    beforeEach ->
      deserializerDisposable = atom.deserializers.add(TestView)
      item1 = new TestView('Item 1')
      item2 = new TestView('Item 2')
      pane = atom.workspace.getActivePane()
      pane.addItem(item1)
      pane.activateItem(item1)
      pane.addItem(item2)
      pane.activateItem(item2)

    fit "switches to the previous buffer", ->
      expect(pane.getActiveItem()).toBe item2
      keydown('6', ctrl: true)
      expect(pane.getActiveItem()).toBe item1

    it "accepts an argument", ->
      expect(pane.getActiveItem()).toBe item2
      keydown('1')
      keydown('^', ctrl: true)
      expect(pane.getActiveItem()).toBe item1

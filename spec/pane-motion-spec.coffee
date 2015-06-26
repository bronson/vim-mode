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

    beforeEach ->
      pane = atom.workspace.getActivePane()
      item1 = new TextEditor()   # need to mock this?
      pane.addItem(item1)
      pane.activateItem(item1)
      # probably need to set item1.lastOpened since it will be the same as item2's
      item2 = new TextEditor()
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

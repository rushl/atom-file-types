{basename, extname} = require 'path'

CONFIG_KEY = 'file-types'

module.exports =
  debug: true

  fileTypes: {}

  _off: []

  activate: (state) ->
    @_off.push atom.config.observe CONFIG_KEY, =>
      @loadConfig atom.config.get CONFIG_KEY

    @_off.push atom.workspaceView.eachEditorView (view) =>
      editor = view.getEditor()
      @_tryToSetGrammar editor

    @_off.push atom.syntax.on 'grammar-added', (g) =>
      for fileType, scopeName of @fileTypes when g.scopeName is scopeName
        for editor in atom.workspace.getEditors()
          @_tryToSetGrammar editor

  deactivate: ->
    o?() for o in @_off

  serialize: ->

  loadConfig: (config = {}) ->
    @fileTypes = {}
    for fileType, scopeName of config
      @fileTypes[".#{fileType}"] = scopeName
    @_log @fileTypes

  _tryToSetGrammar: (editor) ->
    filename = basename editor.getPath()
    ext = extname filename
    unless ext
      @_log 'no extension...skipping'
      return
    scopeName = @fileTypes[ext]
    unless scopeName?
      @_log "no custom scopeName for #{ext}...skipping"
      return
    g = atom.syntax.grammarForScopeName scopeName
    unless g?
      @_log "no grammar for #{scopeName}!?"
      return
    @_log "setting #{scopeName} as grammar for #{filename}"
    editor.setGrammar g

  _log: (argv...) ->
    return unless @debug
    argv.unshift '[file-types]'
    console.debug.apply console, argv

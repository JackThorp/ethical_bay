fs        = require 'fs'
path      = require 'path'
jade      = require 'jade'
express   = require 'express'
stylus    = require 'stylus'
markdown  = (require 'markdown').markdown

JADE_DIR = path.join __dirname, 'views'
PUBLIC_DIR = path.join __dirname, 'public'
MARKDOWN_DIR = path.join __dirname, 'markdown'

module.exports = tools = {

  getMarkdown: (cwd = MARKDOWN_DIR, targets = {}) ->
    [files, folders] = fs.readdirSync(cwd)
      .reduce\
      ( ((a,f) -> a[+fs.statSync(path.join cwd, f).isDirectory()].push f; a)
      , [[],[]])

    for file in files when /\.md$/.test file
      file = path.join cwd, file
      name = file.match(/([^/]+)\.[^.]+$/)[1]
      targets[name] = fs.readFileSync file, 'utf8'

    for dir in folders
      targets = tools.getMarkdown path.join(cwd, dir), targets

    targets

  compileMarkdown: (targets = tools.getMarkdown()) ->
    for own target, src of targets
      targets[target] = markdown.toHTML src
    targets

  compileJade: (jfile, targets = tools.compileMarkdown()) ->
    opts = filename: jfile, pretty: true
    jCompiler = jade.compile (fs.readFileSync jfile, 'utf8'), opts
    jCompiler targets

  servePage: (req, res) ->
    name = req.params.name.match(/([^/]+)\.[^.]+$/)?[1]
    name ?= 'home'
    jf = path.join JADE_DIR, "#{name}.jade"
    res.send tools.compileJade jf
}

if !module.parent?
  app = express()
  app.get '/', (req, res) ->
    res.redirect '/pages/home'
  app.get '/pages/:name', tools.servePage
  app.use stylus.middleware
    src:  __dirname + '/views'
    dest: __dirname + '/public'
    compile:  (str, path) ->
      stylus(str)
        .set 'filename', path
        .set 'compress', false
  
  app.use express.static PUBLIC_DIR
  app.listen (PORT = 3000), (err) ->
    if err? then console.error err
    else
      console.log "Server listening on http://localhost:#{PORT}"


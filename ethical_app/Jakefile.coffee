#!/usr/bin/env coffee
fs            = require 'fs'
compileTools  = require './server'
path          = require 'path'
sSplitter     = require 'stream-splitter'
$q            = require 'q'
spawn         = (require 'child_process').spawn

# Log Styles ####################################################

(styles = {

  # Styles
  bold: [1, 22],        italic: [3, 23]
  underline: [4, 24],   inverse: [7, 27]
  
  # Grayscale
  white: ['01;38;5;271', 0],    grey: ['01;38;5;251', 0]
  black: ['01;38;5;232', 0]

  # Colors
  blue: ['00;38;5;14', 0],      purple: ['00;38;5;98', 0]
  green: ['01;38;5;118', 0],    orange: ['00;38;5;208', 0]
  red: ['01;38;5;196', 0],      pink: ['01;38;5;198', 0]

})

# configure styles into ANSI excape sequence
stylize = (str, style) ->
  [p, s] = styles[style]
  `'\033'`+"[#{p}m#{str}"+`'\033'`+"[#{s}m"

# Hack string object to hook into styles
(Object.keys styles).map (style) ->
  String::__defineGetter__(style, -> stylize @, style)

# Build Helpers #########################################################

# Takes a prefix and a writable stream _w. Returns a stream that when
# written to till pipe input to _w prefixed with pre on every line.
pipePrefix = (pre, _w) ->
  sstream = sSplitter('\n')
  sstream.encoding = 'utf8'
  sstream.on 'token', (token) ->
    _w.write pre+token+'\n'
  return sstream

# Runs comands sequentially returning a promise for command 
# resolution

chain = (cmds..., opt) ->
  run = (cmd, cmds...) ->
    [exe, args, fmsg, check, wd] = cmd
    check ?= (err) -> err == 0
    wd ?= __dirname
    prompt "#{exe} #{args.join ' '}"
    prog = spawn exe, args, cwd: wd
    prog.stdout.pipe pOut
    prog.stderr.pipe pErr
    prog.on 'exit', (err) ->
      do newline if cmds.length is 0
      if !check err
        def.reject err, fmsg
      else if cmds.length != 0 then run cmds...
      else
        do def.resolve

  def = $q.defer()
  promise = def.promise

  #Process lase argument
  if opt instanceof Array
    if opt.length == 1
      [smsg] = opt
      promise.then ->
        succeed smsg
      promise.catch (err, fmsg) ->
        fail "[#{err}] #{fmsg}"
      opt = null
  cmds.push opt if opt?

  # Run commands
  do newline
  run cmds... if cmds.length > 0
  def.promise

# LOGGING ALIASES ##################################################

title = (msg) ->
  console.log "\n> #{msg}".white

log = (msg) ->
  console.log msg.split(/\r\n/).map((l) -> " #{l}").join ''

newline = console.log

succeed = (msg) ->
  console.log "+ #{msg}\n".green

fail = (msg) ->
  console.error "! #{msg}\n".red
  throw new Error msg

prompt = (cmd) ->
  console.log "$ #{cmd}"

pOut = pipePrefix '  ', process.stdout
pErr = pipePrefix '  ', process.stderr


# DEV TASKS #########################################################

JADE_DIR = path.join __dirname, 'views'
PUBLIC_DIR = path.join __dirname, 'public'

desc 'cleans pages folder'
task 'clean-public-pages', [], ->
  title 'cleaning ./public/pages folder'
  chain\
  ( ['rm', ['-rf', './public/pages']]
    ['mkdir', ['-p', './public/pages']]
    ['Successfully recreated pages folder']
  ).finally complete

desc 'compiles jade into public directory'
task 'compile-jade', ['clean-public-pages'], ->
  title 'compilng jade files to ./public/pages'
  [jFiles, jDirs] = fs.readdirSync(JADE_DIR)
    .reduce\
    ( ((a,f) -> a[+fs.statSync(path.join JADE_DIR, f).isDirectory()].push f; a),
      [[],[]])
  for jf in jFiles
    jadePath = path.join JADE_DIR, jf
    log jadePath
    htmlFile = "#{jf.match(/([^/]+)\.jade$/)[1]}.html"
    htmlPath = path.join PUBLIC_DIR, 'pages', htmlFile
    htmlContent = compileTools.compileJade jadePath
    process.stdout.write " Compiling #{htmlFile}..."
    try fs.writeFileSync\
    (htmlPath
    , htmlContent
    , 'utf8' )
    catch err
      fail "\nFailed to write to #{htmlPath}"
    log "done!"
  succeed 'Successfully compiled Jade targets to public'

desc 'compiles static blog folders into public directory'
task 'generate-blog', [], ->
  title 'generating and copying static blog files'
  chain\
  ( ['./gen_blog.sh', []]
  ).finally complete
  succeed 'Successfully regenerated blog'

desc 'assemble public directory'
task 'make-public', ['compile-jade', 'generate-blog'], ->
  succeed 'Successfully generated static files'

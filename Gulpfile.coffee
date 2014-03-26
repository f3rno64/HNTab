gulp = require "gulp"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
uglify = require "gulp-uglify"
rename = require "gulp-rename"
stylus = require "gulp-stylus"
minifycss = require "gulp-minify-css"
clean = require "gulp-clean"
jade = require "gulp-jade"

paths =
  coffee: "coffee/**/*.coffee"
  styl: "stylus/**/*.styl"
  css: "static/css/**/*.css"
  js: "static/js/**/*.js"
  img: "static/img/**/*"
  jade: "hn.jade"
  manifest: "manifest.json"
  dist: "dist/**/*"

# Copy manifest over
gulp.task "manifest", ->
  gulp.src paths.manifest
  .pipe gulp.dest "build/"

# Copy images over
gulp.task "images", ->
  gulp.src paths.img
  .pipe gulp.dest "build/img/"

# Copy dist folder over
gulp.task "dist", ->
  gulp.src paths.dist
  .pipe gulp.dest "build/dist/"

# Compile stylus
gulp.task "stylus", ->
  gulp.src "build/css/**/*", read: false
  .pipe clean()

  gulp.src paths.styl
  .pipe stylus "include css": true
  .pipe gulp.dest "build/css"
  .pipe rename suffix: ".min"
  .pipe minifycss()
  .pipe gulp.dest "build/css"

# Compile vendor css
gulp.task "css", ->
  gulp.src paths.css
  .pipe concat "vendor.css"
  .pipe gulp.dest "build/css"
  .pipe rename suffix: ".min"
  .pipe minifycss()
  .pipe gulp.dest "build/css"

# Compile clientside coffeescript
gulp.task "coffee", ->
  gulp.src paths.coffee
  .pipe coffee()
  .pipe gulp.dest "build/js"
  .pipe concat "script.min.js"
  .pipe uglify()
  .pipe gulp.dest "build/js"

# Compile vendor js
gulp.task "js", ->
  gulp.src "build/js/**/*", read: false
  .pipe clean()

  gulp.src paths.js
  .pipe gulp.dest "build/js"

# Compile static jade files
gulp.task "jade", ->
  gulp.src "build/**/*.html", read: false
  .pipe clean()

  gulp.src paths.jade
  .pipe jade()
  .pipe gulp.dest "build"

# Rerun the task when a file changes
gulp.task "watch", ->
  gulp.watch paths.js, ["js"]
  gulp.watch paths.coffee, ["coffee"]
  gulp.watch paths.styl, ["stylus", "css"]
  gulp.watch paths.css, ["css"]
  gulp.watch paths.jade, ["jade"]
  gulp.watch paths.manifest, ["manifest"]
  gulp.watch paths.img, ["images"]
  gulp.watch paths.dist, ["dist"]

gulp.task "build", ["stylus", "css", "jade", "js", "images", "coffee", "manifest", "dist"]
gulp.task "develop", ["build", "watch"]

# The default task (called when you run `gulp` from cli)
gulp.task "default", ["build"]

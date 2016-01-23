fs   = require 'fs'
gm   = require 'gm'
path = require 'path'

IMG_PATH = path.resolve 'image'


class Image
  constructor: (@path) ->
    @width = 0
    @height = 0

  setWidth: (width) ->
    @width = width

  setHeight: (height) ->
    @height = height


getImgSize = (source) ->
  return new Promise (resolve, reject) ->
    gm source
    .size (err, values) ->
      if err then return reject err
      return resolve values

composite = (params) ->
  return new Promise (resolve, reject) ->
    gm params.source
    .composite params.input
    .geometry "+#{params.coordinate.x}+#{params.coordinate.y}"
    .write params.output, (err) ->
      if err then return reject err
      return resolve 'Fin composite'

resize = (params) ->
  return new Promise (resolve, reject) ->
    gm params.source
    .resize params.width, params.height
    .autoOrient()
    .write params.output, (err) ->
      if err then return reject err
      console.log 'Fin resize'


do ->
  source = new Image "#{IMG_PATH}/sample.png"
  logo = new Image "#{IMG_PATH}/yuruyuri_logo.png"

  promises = [getImgSize(source.path), getImgSize(logo.path)]
  Promise.all promises
  .then (valuesList) ->

    source.setWidth(valuesList[0].width)
    source.setHeight(valuesList[0].height)
    logo.setWidth(valuesList[1].width)
    logo.setHeight(valuesList[1].height)

    compositeParams =
      source:source.path
      input: logo.path
      output: "#{IMG_PATH}/composite_result.png"
      coordinate:
        x: source.width - logo.width - 30
        y: source.height - logo.height - 30
    composite compositeParams

  .then (compositeResult) ->

    console.log compositeResult

    resizeParams =
      source: source.path
      output: "#{IMG_PATH}/resize_result.png"
      width: 320
      height: 240
    resize resizeParams

  .then (resizeResult) ->

    console.log resizeResult

  .catch (err) ->

    console.log err
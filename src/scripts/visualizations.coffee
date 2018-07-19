class ContentEdit.Visualization extends ContentEdit.ResizableElement

  # An editable visualization (e.g <visualization><source src="..." type="..."></visualization>).
  # The `Visualization` element supports 2 special tags to allow the the size of the
  # image to be constrained (data-ce-min-width, data-ce-max-width).
  #
  # NOTE: YouTube and Vimeo provide support for embedding visualizations using the
  # <iframe> tag. For this reason we support both visualization and iframe tags.
  #
  # `sources` should be specified or set against the element as a list of
  # dictionaries containing `src` and `type` key values.

  constructor: (tagName, attributes, sources = []) ->
    super(tagName, attributes)

    # List of sources for <visualization> elements
    @sources = sources

    # Set the aspect ratio for the image based on it's initial width/height
    size = @size()
    @_aspectRatio = size[1] / size[0]

# Read-only properties

  cssTypeName: () ->
    return 'visualization'

  type: () ->
# Return the type of element (this should be the same as the class name)
    return 'Visualization'

  typeName: () ->
# Return the name of the element type (e.g Image, List item)
    return 'Visualization'

  _title: () ->
# Return a title (based on the source) for the visualization. This is intended
# for internal use only.
    return "Visualization"

# Methods

  createDraggingDOMElement: () ->
# Create a DOM element that visually aids the user in dragging the
# element to a new location in the editiable tree structure.
    unless @isMounted()
      return

    helper = super()
    helper.innerHTML = @_title()
    return helper

  html: (indent = '') ->
# Return a HTML string for the node
    le = ContentEdit.LINE_ENDINGS
    return "#{ indent }<visualization#{ @_attributesToString() }>#{ le }" +
      "Visualization" +
      "#{ le }#{ indent }</visualization>"

  mount: () ->
# Mount the element on to the DOM

# Create the DOM element to mount
    @_domElement = document.createElement('visualization')

    # Set the classes for the visualization, we use the wrapping <a> tag's class if
    # it exists, else we use the class applied to the image.
    if @a and @a['class']
      @_domElement.setAttribute('class', @a['class'])

    else if @_attributes['class']
      @_domElement.setAttribute('class', @_attributes['class'])

    # Set any styles for the element
    style = if @_attributes['style'] then @_attributes['style'] else ''

    # Set the size using style
    if @_attributes['width']
      style += "width:#{ @_attributes['width'] }px;"

    if @_attributes['height']
      style += "height:#{ @_attributes['height'] }px;"

    @_domElement.setAttribute('style', style)

    # Set the title of the element (for mouse over)
    @_domElement.setAttribute('data-ce-title', "Visualization")

    super()

  unmount: () ->
# Unmount the element from the DOM
    super()

# Class properties

  @droppers:
    'Image': ContentEdit.Element._dropBoth
    'PreText': ContentEdit.Element._dropBoth
    'Static': ContentEdit.Element._dropBoth
    'Text': ContentEdit.Element._dropBoth
    'Visualization': ContentEdit.Element._dropBoth

# List of allowed drop placements for the class, supported values are:
  @placements: ['above', 'below', 'left', 'right', 'center']

# Class methods

  @fromDOMElement: (domElement) ->
# Convert an element (DOM) to an element of this type
    return new @(
      domElement.tagName,
      @getDOMElementAttributes(domElement)
    )


# Register `ContentEdit.Visualization` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Visualization, 'visualization')
class ContentEdit.Visembed extends ContentEdit.ResizableElement

  # An editable visualization

  constructor: (tagName, attributes, sources = []) ->
    super(tagName, attributes)

    # List of sources for <visembed> elements
    @sources = sources

    # Set the aspect ratio for the image based on it's initial width/height
    size = @size()
    @_aspectRatio = size[1] / size[0]

  # Read-only properties

  cssTypeName: () ->
    return 'visembed'

  type: () ->
    # Return the type of element (this should be the same as the class name)
    return 'Visembed'

  typeName: () ->
    # Return the name of the element type (e.g Image, List item)
    return 'Visualization'

  _title: () ->
    # Return a title (based on the source) for the visembed. This is intended
    # for internal use only.
    return "Visualization"

  # Methods

  resize: (corner, x, y) ->
    # Resize the element
    unless @isMounted() and @can('resize')
      return

    ContentEdit.Root.get().startResizing(this, corner, x, y, false)

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

    # Set any styles for the element
    style =  ''

    # Set the size using style
    if @_attributes['width']
      style += "width:#{ @_attributes['width'] }px;"

    if @_attributes['height']
      style += "height:#{ @_attributes['height'] }px;"

    if @_attributes['style']
      delete @_attributes['style']

    html = "#{ indent }<visembed  #{ @_attributesToString() } style=\"#{ style }\"><visualization></visualization></visembed>"

    return html

  mount: () ->
    # Mount the element on to the DOM

    # Create the DOM element to mount
    @_domElement = document.createElement('visembed')

    # Set the classes for the visembed
    if @_attributes['class']
      @_domElement.setAttribute('class', @_attributes['class'])
    else
      @_domElement.setAttribute('class', 'visembed')

    if not @_attributes['id']
      @_attributes['id'] = "vis-" + performance.now().toString().replace('.', 7)

    @_domElement.setAttribute('id', @_attributes['id'])

    # Set any styles for the element
    style = ''

    # Set the size using style
    if @_attributes['width']
      style += "width:#{ @_attributes['width'] }px;"

    if @_attributes['height']
      style += "height:#{ @_attributes['height'] }px;"

    @_domElement.setAttribute('style', style)

    # Set the title of the element (for mouse over)
    @_domElement.setAttribute('data-ce-title', "Visualization")

    @_domElement.appendChild(document.createElement('visualization'))

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
    'Visembed': ContentEdit.Element._dropBoth

  # List of allowed drop placements for the class, supported values are:
  @placements: ['above', 'below', 'left', 'right', 'center']

  # Class methods

  @fromDOMElement: (domElement) ->
    # Convert an element (DOM) to an element of this type
    return new @(
      domElement.tagName,
      @getDOMElementAttributes(domElement)
    )


# Register `ContentEdit.Visembed` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Visembed, 'visembed')
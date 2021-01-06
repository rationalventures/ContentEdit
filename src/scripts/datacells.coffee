class ContentEdit.Datacell extends ContentEdit.Element

  # An editable visualization

  constructor: (tagName, attributes, sources = []) ->
    super(tagName, attributes)

    # List of sources for <datacell> elements
    @sources = sources

  # Read-only properties

  cssTypeName: () ->
    return 'datacell'

  type: () ->
    # Return the type of element (this should be the same as the class name)
    return 'datacell'

  typeName: () ->
    # Return the name of the element type (e.g Image, List item)
    return 'Code Block'

  _title: () ->
    # Return a title (based on the source) for the datacell. This is intended
    # for internal use only.
    return "Code Block"

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

    # Set any styles for the element
    style =  ''

    if @_attributes['style']
      delete @_attributes['style']

    html = "#{ indent }<datacell  #{ @_attributesToString() } style=\"#{ style }\"><cell></cell></datacell>"

    return html

  mount: () ->
    # Mount the element on to the DOM

    # Create the DOM element to mount
    @_domElement = document.createElement('datacell')

    # Set the classes for the datacell
    if @_attributes['class']
      @_domElement.setAttribute('class', @_attributes['class'])
    else
      @_domElement.setAttribute('class', 'datacell')

    if not @_attributes['id']
      @_attributes['id'] = "vis-" + performance.now().toString().replace('.', 7)

    @_domElement.setAttribute('id', @_attributes['id'])

    # Set any styles for the element
    style = ''

    @_domElement.setAttribute('style', style)

    # Set the title of the element (for mouse over)
    @_domElement.setAttribute('data-ce-title', "Code Block")

    @_domElement.appendChild(document.createElement('cell'))

    super()

  unmount: () ->
    # Unmount the element from the DOM
    super()

  # Class properties

  @droppers:
    'Image': ContentEdit.Element._dropBoth
    'ImageFixture': ContentEdit.Element._dropVert
    'List': ContentEdit.Element._dropVert
    'PreText': ContentEdit.Element._dropVert
    'Static': ContentEdit.Element._dropVert
    'Table': ContentEdit.Element._dropVert
    'Text': ContentEdit.Element._dropVert
    'Video': ContentEdit.Element._dropVert
    'Visembed': ContentEdit.Element._dropVert

  # List of allowed drop placements for the class, supported values are:
  @placements: ['above', 'below', 'left', 'right', 'center']

  # Class methods

  @fromDOMElement: (domElement) ->
    # Convert an element (DOM) to an element of this type
    return new @(
      domElement.tagName,
      @getDOMElementAttributes(domElement)
    )


# Register `ContentEdit.Datacell` the class with associated tag names
ContentEdit.TagNames.get().register(ContentEdit.Datacell, 'datacell')
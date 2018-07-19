# Visualization

describe '`ContentEdit.Visualization()`', () ->

    it 'should return an instance of Visualization`', () ->

        # Wihtout a link
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'})
        expect(visualization instanceof ContentEdit.Visualization).toBe true

        # With a link
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'}, {'href': 'bar'})
        expect(visualization instanceof ContentEdit.Visualization).toBe true


describe '`ContentEdit.Visualization.cssTypeName()`', () ->

    it 'should return \'visualization\'', () ->
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'})
        expect(visualization.cssTypeName()).toBe 'visualization'


describe '`ContentEdit.Visualization.type()`', () ->

    it 'should return \'Visualization\'', () ->
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'})
        expect(visualization.type()).toBe 'Visualization'


describe '`ContentEdit.Visualization.typeName()`', () ->

    it 'should return \'Visualization\'', () ->
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'})
        expect(visualization.typeName()).toBe 'Visualization'


describe '`ContentEdit.Visualization.createDraggingDOMElement()`', () ->

    it 'should create a helper DOM element', () ->
        # Mount an visualization to a region
        visualization = new ContentEdit.Visualization({'src': 'http://getme.co.uk/foo.jpg'})
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(visualization)

        # Get the helper DOM element
        helper = visualization.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(
            helper.style.backgroundVisualization.replace(/"/g, '')
            ).toBe 'url(http://getme.co.uk/foo.jpg)'


describe '`ContentEdit.Visualization.html()`', () ->

    it 'should return a HTML string for the visualization', () ->

        # Without a link
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'})
        expect(visualization.html()).toBe '<vis src="/foo.jpg">'

        # With a link
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'}, {'href': 'bar'})
        expect(visualization.html()).toBe(
            '<a href="bar" data-ce-tag="vis">\n' +
                "#{ ContentEdit.INDENT }<vis src=\"/foo.jpg\">\n" +
            '</a>'
            )

describe '`ContentEdit.Visualization.mount()`', () ->

    visualizationA = null
    visualizationB = null
    region = null

    beforeEach ->
        visualizationA = new ContentEdit.Visualization({'src': '/foo.jpg'})
        visualizationB = new ContentEdit.Visualization({'src': '/foo.jpg'}, {'href': 'bar'})

        # Mount the visualizations
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(visualizationA)
        region.attach(visualizationB)
        visualizationA.unmount()
        visualizationB.unmount()

    it 'should mount the visualization to the DOM', () ->
        visualizationA.mount()
        visualizationB.mount()
        expect(visualizationA.isMounted()).toBe true
        expect(visualizationB.isMounted()).toBe true

    it 'should trigger the `mount` event against the root', () ->

        # Create a function to call when the event is triggered
        foo = {
            handleFoo: () ->
                return
        }
        spyOn(foo, 'handleFoo')

        # Bind the function to the root for the mount event
        root = ContentEdit.Root.get()
        root.bind('mount', foo.handleFoo)

        # Mount the visualization
        visualizationA.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(visualizationA)


describe '`ContentEdit.Visualization.fromDOMElement()`', () ->

    it 'should convert a <vis> DOM element into an visualization element', () ->
        # Create <vis> DOM element
        domvis = document.createElement('vis')
        domvis.setAttribute('src', '/foo.jpg')
        domvis.setAttribute('width', '400')
        domvis.setAttribute('height', '300')

        # Convert the DOM element into an visualization element
        vis = ContentEdit.Visualization.fromDOMElement(domvis)

        expect(vis.html()).toBe '<vis height="300" src="/foo.jpg" width="400">'

    it 'should read the natural width of the visualization if not supplied as an
        attribute', () ->

        # Create <vis> DOM element (with inline source so we can test querying
        # the size of the visualization, inline visualizations are loaded as soon as the source
        # is set).
        domvis = document.createElement('vis')
        domvis.setAttribute(
            'src',
            'data:visualization/gif;' +
            'base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
            )

        # Convert the DOM element into an visualization element
        vis = ContentEdit.Visualization.fromDOMElement(domvis)

        expect(vis.size()).toEqual [1, 1]

    it 'should convert a wrapped <a><vis></a> DOM element into an visualization \
        element', () ->

        # Create <a> DOM element
        domA = document.createElement('a')
        domA.setAttribute('href', 'test')

        # Create <vis> DOM element
        domvis = document.createElement('vis')
        domvis.setAttribute('src', '/foo.jpg')
        domvis.setAttribute('width', '400')
        domvis.setAttribute('height', '300')
        domA.appendChild(domvis)

        # Convert the DOM element into an visualization element
        vis = ContentEdit.Visualization.fromDOMElement(domA)

        expect(vis.html()).toBe(
            '<a href="test" data-ce-tag="vis">\n' +
                "#{ ContentEdit.INDENT }" +
                '<vis height="300" src="/foo.jpg" width="400">\n' +
            '</a>'
            )


# Droppers

describe '`ContentEdit.Visualization` drop interactions', () ->

    visualization = null
    region = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        visualization = new ContentEdit.Visualization({'src': '/foo.jpg'})
        region.attach(visualization)

    it 'should support dropping on Visualization', () ->
        otherVisualization = new ContentEdit.Visualization({'src': '/bar.jpg'})
        region.attach(otherVisualization)

        # Check the initial order
        expect(visualization.nextSibling()).toBe otherVisualization

        # Check the order and class above dropping the element left
        visualization.drop(otherVisualization, ['above', 'left'])
        expect(visualization.hasCSSClass('align-left')).toBe true
        expect(visualization.nextSibling()).toBe otherVisualization

        # Check the order and class above dropping the element right
        visualization.drop(otherVisualization, ['above', 'right'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe true
        expect(visualization.nextSibling()).toBe otherVisualization

        # Check the order after dropping the element below
        visualization.drop(otherVisualization, ['below', 'center'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe false
        expect(otherVisualization.nextSibling()).toBe visualization

        # Check the order after dropping the element above
        visualization.drop(otherVisualization, ['above', 'center'])
        expect(visualization.nextSibling()).toBe otherVisualization

    it 'should support dropping on PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText)

        # Check the initial order
        expect(visualization.nextSibling()).toBe preText

        # Check the order and class above dropping the element left
        visualization.drop(preText, ['above', 'left'])
        expect(visualization.hasCSSClass('align-left')).toBe true
        expect(visualization.nextSibling()).toBe preText

        # Check the order and class above dropping the element right
        visualization.drop(preText, ['above', 'right'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe true
        expect(visualization.nextSibling()).toBe preText

        # Check the order after dropping the element below
        visualization.drop(preText, ['below', 'center'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe false
        expect(preText.nextSibling()).toBe visualization

        # Check the order after dropping the element above
        visualization.drop(preText, ['above', 'center'])
        expect(visualization.nextSibling()).toBe preText

    it 'should support being dropped on by PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText, 0)

        # Check the initial order
        expect(preText.nextSibling()).toBe visualization

        # Check the order after dropping the element below
        preText.drop(visualization, ['below', 'center'])
        expect(visualization.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(visualization, ['above', 'center'])
        expect(preText.nextSibling()).toBe visualization

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(visualization.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element left
        visualization.drop(staticElm, ['above', 'left'])
        expect(visualization.hasCSSClass('align-left')).toBe true
        expect(visualization.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element right
        visualization.drop(staticElm, ['above', 'right'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe true
        expect(visualization.nextSibling()).toBe staticElm

        # Check the order after dropping the element below
        visualization.drop(staticElm, ['below', 'center'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe false
        expect(staticElm.nextSibling()).toBe visualization

        # Check the order after dropping the element above
        visualization.drop(staticElm, ['above', 'center'])
        expect(visualization.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe visualization

        # Check the order after dropping the element below
        staticElm.drop(visualization, ['below', 'center'])
        expect(visualization.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(visualization, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe visualization

    it 'should support dropping on Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text)

        # Check the initial order
        expect(visualization.nextSibling()).toBe text

        # Check the order and class above dropping the element left
        visualization.drop(text, ['above', 'left'])
        expect(visualization.hasCSSClass('align-left')).toBe true
        expect(visualization.nextSibling()).toBe text

        # Check the order and class above dropping the element right
        visualization.drop(text, ['above', 'right'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe true
        expect(visualization.nextSibling()).toBe text

        # Check the order after dropping the element below
        visualization.drop(text, ['below', 'center'])
        expect(visualization.hasCSSClass('align-left')).toBe false
        expect(visualization.hasCSSClass('align-right')).toBe false
        expect(text.nextSibling()).toBe visualization

        # Check the order after dropping the element above
        visualization.drop(text, ['above', 'center'])
        expect(visualization.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe visualization

        # Check the order after dropping the element below
        text.drop(visualization, ['below', 'center'])
        expect(visualization.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(visualization, ['above', 'center'])
        expect(text.nextSibling()).toBe visualization

# visembed

describe '`ContentEdit.visembed()`', () ->

    it 'should return an instance of visembed`', () ->

        # Wihtout a link
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'})
        expect(visembed instanceof ContentEdit.visembed).toBe true

        # With a link
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'}, {'href': 'bar'})
        expect(visembed instanceof ContentEdit.visembed).toBe true


describe '`ContentEdit.visembed.cssTypeName()`', () ->

    it 'should return \'visembed\'', () ->
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'})
        expect(visembed.cssTypeName()).toBe 'visembed'


describe '`ContentEdit.visembed.type()`', () ->

    it 'should return \'visembed\'', () ->
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'})
        expect(visembed.type()).toBe 'visembed'


describe '`ContentEdit.visembed.typeName()`', () ->

    it 'should return \'visembed\'', () ->
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'})
        expect(visembed.typeName()).toBe 'visembed'


describe '`ContentEdit.visembed.createDraggingDOMElement()`', () ->

    it 'should create a helper DOM element', () ->
        # Mount an visembed to a region
        visembed = new ContentEdit.visembed({'src': 'http://getme.co.uk/foo.jpg'})
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(visembed)

        # Get the helper DOM element
        helper = visembed.createDraggingDOMElement()

        expect(helper).not.toBe null
        expect(helper.tagName.toLowerCase()).toBe 'div'
        expect(
            helper.style.backgroundvisembed.replace(/"/g, '')
            ).toBe 'url(http://getme.co.uk/foo.jpg)'


describe '`ContentEdit.visembed.html()`', () ->

    it 'should return a HTML string for the visembed', () ->

        # Without a link
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'})
        expect(visembed.html()).toBe '<vis src="/foo.jpg">'

        # With a link
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'}, {'href': 'bar'})
        expect(visembed.html()).toBe(
            '<a href="bar" data-ce-tag="vis">\n' +
                "#{ ContentEdit.INDENT }<vis src=\"/foo.jpg\">\n" +
            '</a>'
            )

describe '`ContentEdit.visembed.mount()`', () ->

    visembedA = null
    visembedB = null
    region = null

    beforeEach ->
        visembedA = new ContentEdit.visembed({'src': '/foo.jpg'})
        visembedB = new ContentEdit.visembed({'src': '/foo.jpg'}, {'href': 'bar'})

        # Mount the visembeds
        region = new ContentEdit.Region(document.createElement('div'))
        region.attach(visembedA)
        region.attach(visembedB)
        visembedA.unmount()
        visembedB.unmount()

    it 'should mount the visembed to the DOM', () ->
        visembedA.mount()
        visembedB.mount()
        expect(visembedA.isMounted()).toBe true
        expect(visembedB.isMounted()).toBe true

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

        # Mount the visembed
        visembedA.mount()
        expect(foo.handleFoo).toHaveBeenCalledWith(visembedA)


describe '`ContentEdit.visembed.fromDOMElement()`', () ->

    it 'should convert a <vis> DOM element into an visembed element', () ->
        # Create <vis> DOM element
        domvis = document.createElement('vis')
        domvis.setAttribute('src', '/foo.jpg')
        domvis.setAttribute('width', '400')
        domvis.setAttribute('height', '300')

        # Convert the DOM element into an visembed element
        vis = ContentEdit.visembed.fromDOMElement(domvis)

        expect(vis.html()).toBe '<vis height="300" src="/foo.jpg" width="400">'

    it 'should read the natural width of the visembed if not supplied as an
        attribute', () ->

        # Create <vis> DOM element (with inline source so we can test querying
        # the size of the visembed, inline visembeds are loaded as soon as the source
        # is set).
        domvis = document.createElement('vis')
        domvis.setAttribute(
            'src',
            'data:visembed/gif;' +
            'base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='
            )

        # Convert the DOM element into an visembed element
        vis = ContentEdit.visembed.fromDOMElement(domvis)

        expect(vis.size()).toEqual [1, 1]

    it 'should convert a wrapped <a><vis></a> DOM element into an visembed \
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

        # Convert the DOM element into an visembed element
        vis = ContentEdit.visembed.fromDOMElement(domA)

        expect(vis.html()).toBe(
            '<a href="test" data-ce-tag="vis">\n' +
                "#{ ContentEdit.INDENT }" +
                '<vis height="300" src="/foo.jpg" width="400">\n' +
            '</a>'
            )


# Droppers

describe '`ContentEdit.visembed` drop interactions', () ->

    visembed = null
    region = null

    beforeEach ->
        region = new ContentEdit.Region(document.createElement('div'))
        visembed = new ContentEdit.visembed({'src': '/foo.jpg'})
        region.attach(visembed)

    it 'should support dropping on visembed', () ->
        othervisembed = new ContentEdit.visembed({'src': '/bar.jpg'})
        region.attach(othervisembed)

        # Check the initial order
        expect(visembed.nextSibling()).toBe othervisembed

        # Check the order and class above dropping the element left
        visembed.drop(othervisembed, ['above', 'left'])
        expect(visembed.hasCSSClass('align-left')).toBe true
        expect(visembed.nextSibling()).toBe othervisembed

        # Check the order and class above dropping the element right
        visembed.drop(othervisembed, ['above', 'right'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe true
        expect(visembed.nextSibling()).toBe othervisembed

        # Check the order after dropping the element below
        visembed.drop(othervisembed, ['below', 'center'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe false
        expect(othervisembed.nextSibling()).toBe visembed

        # Check the order after dropping the element above
        visembed.drop(othervisembed, ['above', 'center'])
        expect(visembed.nextSibling()).toBe othervisembed

    it 'should support dropping on PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText)

        # Check the initial order
        expect(visembed.nextSibling()).toBe preText

        # Check the order and class above dropping the element left
        visembed.drop(preText, ['above', 'left'])
        expect(visembed.hasCSSClass('align-left')).toBe true
        expect(visembed.nextSibling()).toBe preText

        # Check the order and class above dropping the element right
        visembed.drop(preText, ['above', 'right'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe true
        expect(visembed.nextSibling()).toBe preText

        # Check the order after dropping the element below
        visembed.drop(preText, ['below', 'center'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe false
        expect(preText.nextSibling()).toBe visembed

        # Check the order after dropping the element above
        visembed.drop(preText, ['above', 'center'])
        expect(visembed.nextSibling()).toBe preText

    it 'should support being dropped on by PreText', () ->
        preText = new ContentEdit.PreText('pre', {}, '')
        region.attach(preText, 0)

        # Check the initial order
        expect(preText.nextSibling()).toBe visembed

        # Check the order after dropping the element below
        preText.drop(visembed, ['below', 'center'])
        expect(visembed.nextSibling()).toBe preText

        # Check the order after dropping the element above
        preText.drop(visembed, ['above', 'center'])
        expect(preText.nextSibling()).toBe visembed

    it 'should support dropping on Static', () ->
        staticElm = ContentEdit.Static.fromDOMElement(
            document.createElement('div')
            )
        region.attach(staticElm)

        # Check the initial order
        expect(visembed.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element left
        visembed.drop(staticElm, ['above', 'left'])
        expect(visembed.hasCSSClass('align-left')).toBe true
        expect(visembed.nextSibling()).toBe staticElm

        # Check the order and class above dropping the element right
        visembed.drop(staticElm, ['above', 'right'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe true
        expect(visembed.nextSibling()).toBe staticElm

        # Check the order after dropping the element below
        visembed.drop(staticElm, ['below', 'center'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe false
        expect(staticElm.nextSibling()).toBe visembed

        # Check the order after dropping the element above
        visembed.drop(staticElm, ['above', 'center'])
        expect(visembed.nextSibling()).toBe staticElm

    it 'should support being dropped on by `moveable` Static', () ->
        staticElm = new ContentEdit.Static('div', {'data-ce-moveable'}, 'foo')
        region.attach(staticElm, 0)

        # Check the initial order
        expect(staticElm.nextSibling()).toBe visembed

        # Check the order after dropping the element below
        staticElm.drop(visembed, ['below', 'center'])
        expect(visembed.nextSibling()).toBe staticElm

        # Check the order after dropping the element above
        staticElm.drop(visembed, ['above', 'center'])
        expect(staticElm.nextSibling()).toBe visembed

    it 'should support dropping on Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text)

        # Check the initial order
        expect(visembed.nextSibling()).toBe text

        # Check the order and class above dropping the element left
        visembed.drop(text, ['above', 'left'])
        expect(visembed.hasCSSClass('align-left')).toBe true
        expect(visembed.nextSibling()).toBe text

        # Check the order and class above dropping the element right
        visembed.drop(text, ['above', 'right'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe true
        expect(visembed.nextSibling()).toBe text

        # Check the order after dropping the element below
        visembed.drop(text, ['below', 'center'])
        expect(visembed.hasCSSClass('align-left')).toBe false
        expect(visembed.hasCSSClass('align-right')).toBe false
        expect(text.nextSibling()).toBe visembed

        # Check the order after dropping the element above
        visembed.drop(text, ['above', 'center'])
        expect(visembed.nextSibling()).toBe text

    it 'should support being dropped on by Text', () ->
        text = new ContentEdit.Text('p')
        region.attach(text, 0)

        # Check the initial order
        expect(text.nextSibling()).toBe visembed

        # Check the order after dropping the element below
        text.drop(visembed, ['below', 'center'])
        expect(visembed.nextSibling()).toBe text

        # Check the order after dropping the element above
        text.drop(visembed, ['above', 'center'])
        expect(text.nextSibling()).toBe visembed

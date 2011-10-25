###
# Main module, define namespaces and some useful funcs #
###

# Namespaces
window.CC = {}
window.CC = {}
window.CC.views = {}
window.CC.views.draw = {} # Classes used by the draw area
window.CC.views.draw.primitives = {}
window.CC.views.draw.tools = {}
window.CC.views.gui = {} # Classes that defined GUI widgets
window.CC.views.gui.tools = {} # Classes that defined GUI widgets
window.CC.controllers = {}
window.CC.models = {}

Math.guid=->
    s = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    f=(c)->
        r = Math.random()*16|0
        if (c=="x")
            v=r
        else
            v = (r&0x3|0x8)
        return v.toString(16)
    return s.replace(/[xy]/g,f).toUpperCase()

window.debug = (obj, message)->
    console.log(obj, message)
Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1
$(document).ready ->
    mainController = new CC.controllers.Main()

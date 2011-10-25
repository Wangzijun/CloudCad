class CC.views.draw.Stage2d extends CC.views.Abstract
    @activePath
    @mouse
    constructor:()->
        #paper.install(window)
        $(document.body).append($("<canvas></canvas>").attr("id","canvas2d").attr("resize","true"))
        paper.setup("canvas2d")

        @mouse = new CC.views.draw.Mouse()
        
        @clickTolerance = 15
        @snapTolerance = 8

        #Gestione dei tools
        @pathTool = new CC.views.draw.PathTool(this)
        @selectTool = new CC.views.draw.SelectTool(this)
        @activeTool = @selectTool


        #Gestione degli eventi
        Spine.bind 'mouse:btn1_down', =>
            @activeTool.mouseDown(@mouse.currentPos)
        Spine.bind 'mouse:btn1_drag', =>
            @activeTool.mouseDragged(@mouse.currentPos)
        Spine.bind 'mouse:btn1_up', =>
            @activeTool.mouseUp(@mouse.currentPos)

        
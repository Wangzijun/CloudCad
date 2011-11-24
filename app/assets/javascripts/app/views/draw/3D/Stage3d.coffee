define(
    "views/draw/3D/Stage3d"
    ["views/Abstract", "views/Camera", "views/Mouse", "views/Keyboard", "views/CameraController","views/draw/3D/primitives/Path3D"],
    (Abstract, Camera, Mouse, Keyboard, CameraController,Path3D)->
        class CC.views.draw.Stage3d extends Abstract
            ###
            This class represent the Stage area where all the elements are represented
            ###
            @rotationScale
            @camera
            @scene
            @renderer
            @geometry
            @material
            @mesh
            @light
            @ambientLight
            @origin
            @selectedMesh

            constructor:(@glOrNot)->
                super()
                @rotationScale = 0.003
                @zoomScale = 4
                @zoom = 1
                @lastvert =0
                
                #@camera.toOrthographic()

                # Create the real Scene
                @scene = new THREE.Scene()
                @projector = new THREE.Projector()


                @world = new THREE.Object3D()
                @scene.add(@world)

                # Setup camera
                @camera = new Camera((window.innerWidth),(window.innerHeight-40),35, 1, 15000,1, 15000)
                @camera.position.z = 1000 * @zoom
                @scene.add(@camera)
                #@camera.lookAt(@world)
                #@mouse = new CC.views.draw.Mouse(@camera)

                # Add a light
                @light1 = new THREE.SpotLight(0xFFFFFF,1.0,2.0)
                @light1.position.set( 400, 300, 400 )
                @scene.add( @light1 )

                @light2 = new THREE.SpotLight(0xFFFFFF,0.6,2.0)
                @light2.position.set( 400, 300, -600 )
                @scene.add( @light2 )

                @light3 = new THREE.SpotLight(0xFFFFFF,0.4,2.0)
                @light3.position.set( -400, -300, -600 )
                @scene.add( @light3 )

                # Add ambient light
                @ambientLight = new THREE.AmbientLight( 0xffffff )
                @scene.add(@ambientLight)
                
                @cameraPlane = new THREE.Mesh( new THREE.PlaneGeometry( 2000, 2000, 1, 1 ), new THREE.MeshBasicMaterial( { color: 0x000000, opacity: 0.25, transparent: false, wireframe: false } ) )
                @cameraPlane.lookAt( @camera.position )
                @cameraPlane.visible = false
                @scene.add(@cameraPlane)
                
                
                planeX = new THREE.Mesh( new THREE.PlaneGeometry( 600, 400, 2, 2 ), new THREE.MeshBasicMaterial( { 
                            color: 0xaa0000
                            opacity: .3
                            transparent: false
                            wireframe: true
                        }))

                planeY = new THREE.Mesh( new THREE.PlaneGeometry( 600, 400, 2, 2 ), new THREE.MeshBasicMaterial( { 
                            color: 0x00aa00
                            opacity: .3
                            transparent: false
                            wireframe: true
                        }))
                planeY.rotation.x = Math.toRadian(90) #1.570796327

                planeZ = new THREE.Mesh( new THREE.PlaneGeometry( 600, 400, 2, 2 ), new THREE.MeshBasicMaterial( { 
                            color: 0x0000aa
                            opacity: .3
                            transparent: false
                            wireframe: true
                        }))
                planeZ.rotation.y = Math.toRadian(90) #1.570796327
                
                @scene.add(planeX)
                @scene.add(planeY)
                @scene.add(planeZ)


                # Setup a renderer
                @canvas = document.createElement( 'canvas' )
                $(@canvas).attr("id","canvas3d")
                if glOrNot == "canvas"
                    @renderer =new THREE.CanvasRenderer({canvas:@canvas})
                else if glOrNot == "svg"
                    @renderer =new THREE.SVGRenderer({canvas:@canvas})
                else
                    @renderer = new THREE.WebGLRenderer({
                        antialias: true
                        canvas: @canvas
                        clearColor: 0x111188
                        clearAlpha: 0.2
                        maxLights: 4
                        #stencil: true
                        preserveDrawingBuffer: false
                        sortObjects:true
                    })
                    #@renderer.setFaceCulling("back","cw")

                @mouse = new Mouse($(@canvas))
                @keyboard = new Keyboard()

                @cameraController = new CameraController(this)
                @cameraController.movementSpeed = 75;
                @cameraController.lookSpeed = 0.125;
                @cameraController.lookVertical = false;


                # Define rendere size
                @renderer.setSize( window.innerWidth, window.innerHeight-50 )
                @renderer.shadowMapEnabled = true;
                @renderer.shadowMapSoft = true;

                @renderer.shadowCameraNear = 3;
                @renderer.shadowCameraFar = @camera.far;
                @renderer.shadowCameraFov = 50;

                @renderer.shadowMapBias = 0.0039;
                @renderer.shadowMapDarkness = 0.5;
                @renderer.shadowMapWidth = 1024;
                @renderer.shadowMapHeight = 1024;
                # Add the element to the DOM
                document.body.appendChild( @renderer.domElement )

                window.stage3d = this
                @createGeom()

                # Event listeners
                Spine.bind 'mouse:btn1_down', =>
                    unless @keyboard.isAnyDown()
                        c = @getMouseTarget()
                        if c? and c.length>0
                            if c[0].object? and c[0].object != @cameraPlane
                                obj = c[0].object
                                if @selectedMesh?
                                    @selectedMesh.material.color.setHex(0x53aabb)
                                #debugger
                                obj.material.color.setHex(0x0000bb)
                                @selectedMesh = obj
                            else
                                @selectedMesh = null
                        else
                            @selectedMesh = null

                Spine.bind 'mouse:btn1_drag', =>
                    unless @keyboard.isAnyDown()
                        if (!@selectedMesh and !@selectedParticle) || @mouse.btn1.delta.w * 1 != @mouse.btn1.delta.w || @mouse.btn1.delta.h * 1 != @mouse.btn1.delta.h
                            return

                        if @selectedMesh?
                            @cameraPlane.position.copy( @selectedMesh.position )

                        else if @selectedParticle?
                            @cameraPlane.position.copy( @selectedParticle.position )

                        intersects = @getMouseTarget(@cameraPlane)
                        #debugger
                        if intersects[0]? and @selectedMesh.placeholder==true
                            intersects[0].object.position.copy(@selectedMesh.position)
                        #if intersects[0]?
                            newPoint = intersects[0].point.clone()
                            @selectedMesh.position.x = newPoint.x
                            @selectedMesh.position.y = newPoint.y

                            @linea.movePoint(@selectedMesh.vertexIndex , @selectedMesh.position) 
                
                Spine.bind 'mouse:btn1_up', =>
                    if @selectedMesh?
                        @selectedMesh.material.color.setHex(0x53aabb)

                Spine.bind 'keyboard:67_up', =>
                    @camera.toggleType()

                Spine.bind 'keyboard:49_up', =>         # 1
                    if @keyboard.isKeyDown("alt")
                        @cameraController.toFrontView()

                Spine.bind 'keyboard:50_up', =>         # 2
                    if @keyboard.isKeyDown("alt")
                        @cameraController.toBackView()

                Spine.bind 'keyboard:51_up', =>         # 3
                    if @keyboard.isKeyDown("alt")
                        @cameraController.toTopView()

                Spine.bind 'keyboard:52_up', =>         # 4
                    if @keyboard.isKeyDown("alt")
                        @cameraController.toBottomView()

                Spine.bind 'keyboard:192_up', =>         # 5
                    #if @keyboard.isKeyDown("alt")
                    @cameraController.toLeftView()

                Spine.bind 'keyboard:54_up', =>         # 6
                    if @keyboard.isKeyDown("alt")
                        @cameraController.toRightView()
                                                                        
                
            animate:=>
                requestAnimFrame(@animate)
                @render()

            render:=>
                @cameraController.update()
                @cameraPlane.lookAt( @camera.position );
                @renderer.render(@scene,@camera)

            getMouseTarget:(object)=>  
                if @camera.inPersepectiveMode
                    vector = new THREE.Vector3(
                        @mouse.currentPos.stage3Dx
                        @mouse.currentPos.stage3Dy
                        0.5
                    )
                    @projector.unprojectVector(vector, @camera)
                    ray = new THREE.Ray(@camera.position, vector.subSelf( @camera.position ).normalize())
                    if object? 
                        return ray.intersectObject(object) 
                    else 
                        return ray.intersectObject(@world)
                else
                    vecOrigin = new THREE.Vector3( 
                        @mouse.currentPos.stage3Dx
                        @mouse.currentPos.stage3Dy
                        -1
                    )
                    vecTarget = new THREE.Vector3( 
                        @mouse.currentPos.stage3Dx
                        @mouse.currentPos.stage3Dy
                        1
                    )

                    @projector.unprojectVector( vecOrigin, @camera )
                    @projector.unprojectVector( vecTarget, @camera )
                    vecTarget.subSelf( vecOrigin ).normalize()
                    ray = new THREE.Ray( @camera.position, vecTarget.subSelf( @camera.position ).normalize())
                    ray.origin = vecOrigin
                    ray.direction = vecTarget
                    if object?
                        return ray.intersectObject(object) 
                    else
                        return ray.intersectObject(@world)

            createGeom:=>
                @vertices =[
                    new THREE.Vector2(0,0)
                    new THREE.Vector2(0,100)
                    new THREE.Vector2(100,100)
                    new THREE.Vector2(100,0)
                    new THREE.Vector2(0,0)
                ]
                @linea = new Path3D({
                    points: @vertices
                })
                #@world.add(@linea.threePath)
)


define(
    "views/draw/Camera",
    ()->
        class CC.views.draw.Camera extends THREE.Camera
            constructor:(@width, @height,@fov,@pNear,@pFar, @oNear, @oFar)->
                super()
                @perspective = true
                
                @left = -@width / 2
                @right = @width / 2
                @top = @height / 2
                @bottom = -@height / 2

                @cameraO = new THREE.OrthographicCamera( @width / - 2, @width / 2, @height / 2, @height / - 2,  @oNear, @oFar );
                @cameraP = new THREE.PerspectiveCamera( @fov, @width/@height, @pNear, @pFar );
                
                @zoom = 1
                
                @toPerspective()
                
                @aspect = @width/@height
            
            toPerspective:=>
                @near = @cameraP.near;
                @far = @cameraP.far;
                @cameraP.fov =  @fov / @zoom ;
                @cameraP.updateProjectionMatrix();
                @projectionMatrix = @cameraP.projectionMatrix;
                
                @inPersepectiveMode = true;
                @inOrthographicMode = false;
                
            
            toOrthographic:=>
                fov = @fov
                aspect = @aspect
                near = @pNear
                far = @pFar

                hyperfocus = ( near + far ) / 2 
                
                halfHeight = Math.tan( @zoom / 2 ) * hyperfocus
                planeHeight = 2 * halfHeight
                planeWidth = planeHeight * aspect
                halfWidth = planeWidth / 2
                
                halfHeight /= @fov
                halfWidth /= @fov
                #debugger
                @cameraO.left = -halfWidth
                @cameraO.right = halfWidth
                @cameraO.top = halfHeight
                @cameraO.bottom = -halfHeight
                        
                @cameraO.updateProjectionMatrix()

                @near = @cameraO.near
                @far = @cameraO.far
                @projectionMatrix = @cameraO.projectionMatrix
                
                @inPersepectiveMode = false
                @inOrthographicMode = true
                
            
            setFov:(@fov)=>    
                if @inPersepectiveMode
                    @toPerspective()
                else
                    @toOrthographic()
                
            
            setLens:(focalLength, framesize = 43.25)=>  # 36x24mm
                fov = 2 * Math.atan( framesize / (focalLength * 2))
                fov = 180 / Math.PI * fov
                @setFov(fov)
                return fov
            
            setZoom:(@zoom)=>
                if @inPersepectiveMode
                    @toPerspective()
                else
                    @toOrthographic()

            toFrontView:=>
                @rotation.x = 0
                @position.x = 0
                
                @rotation.y = 0
                @position.y = 0
                
                @rotation.z = 0
                @position.z = 400
                
                @rotationAutoUpdate = false
            toBackView:=>
                @rotation.x = 0
                @rotation.y = Math.PI
                @rotation.z = 0
                @rotationAutoUpdate = false
            
            toLeftView:=>
                @rotation.x = 0
                @rotation.y = - Math.PI / 2
                @rotation.z = 0
                @rotationAutoUpdate = false

            toRightView:=>
                @rotation.x = 0
                @rotation.y = Math.PI / 2
                @rotation.z = 0
                @rotationAutoUpdate = false


            toTopView:=>
                @rotation.x = - Math.PI / 2
                @rotation.y = 0
                @rotation.z = 0
                @rotationAutoUpdate = false


            toBottomView:=>
                @rotation.x = Math.PI / 2
                @rotation.y = 0
                @rotation.z = 0
                @rotationAutoUpdate = false


            toggleType:->
                if @perspective
                    #@setFov(1)
                    #@setZoom(35)
                    @toOrthographic()
                    @perspective = false
                else
                    #@setFov(35)
                    #@setZoom(1)
                    @toPerspective()
                    @perspective = true

// ============================================
// FotbollsMatte 3D - Three.js Stadium
// ============================================

class Stadium3D {
    constructor() {
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.ball = null;
        this.goalkeeper = null;
        this.goalNet = null;
        this.particles = [];
        this.lights = [];
        this.isAnimatingBall = false;
        this.clock = new THREE.Clock();
        
        this.init();
    }

    init() {
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x1a1a2e);
        this.scene.fog = new THREE.Fog(0x1a1a2e, 50, 150);

        // Camera
        this.camera = new THREE.PerspectiveCamera(
            60,
            window.innerWidth / window.innerHeight,
            0.1,
            1000
        );
        this.camera.position.set(0, 15, 35);
        this.camera.lookAt(0, 0, -10);

        // Renderer
        this.renderer = new THREE.WebGLRenderer({ 
            antialias: true,
            alpha: true 
        });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        
        document.getElementById('game-container').appendChild(this.renderer.domElement);

        // Controls
        this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.maxPolarAngle = Math.PI / 2.2;
        this.controls.minDistance = 15;
        this.controls.maxDistance = 60;
        this.controls.target.set(0, 0, -10);

        // Build the stadium
        this.createLights();
        this.createField();
        this.createGoal();
        this.createBall();
        this.createGoalkeeper();
        this.createStadium();
        this.createCrowd();
        this.createAtmosphere();

        // Events
        window.addEventListener('resize', () => this.onResize());

        // Start animation loop
        this.animate();
    }

    createLights() {
        // Ambient light
        const ambient = new THREE.AmbientLight(0xffffff, 0.4);
        this.scene.add(ambient);

        // Main spotlight (sun/stadium lights)
        const mainLight = new THREE.DirectionalLight(0xffffff, 1);
        mainLight.position.set(30, 50, 30);
        mainLight.castShadow = true;
        mainLight.shadow.mapSize.width = 2048;
        mainLight.shadow.mapSize.height = 2048;
        mainLight.shadow.camera.near = 10;
        mainLight.shadow.camera.far = 100;
        mainLight.shadow.camera.left = -50;
        mainLight.shadow.camera.right = 50;
        mainLight.shadow.camera.top = 50;
        mainLight.shadow.camera.bottom = -50;
        this.scene.add(mainLight);

        // Stadium floodlights
        const floodlightPositions = [
            { x: -30, y: 25, z: -30, color: 0xffffee },
            { x: 30, y: 25, z: -30, color: 0xffffee },
            { x: -30, y: 25, z: 10, color: 0xffffee },
            { x: 30, y: 25, z: 10, color: 0xffffee }
        ];

        floodlightPositions.forEach(pos => {
            const light = new THREE.SpotLight(pos.color, 0.5);
            light.position.set(pos.x, pos.y, pos.z);
            light.target.position.set(0, 0, -10);
            light.angle = Math.PI / 4;
            light.penumbra = 0.3;
            light.castShadow = true;
            this.scene.add(light);
            this.scene.add(light.target);
            this.lights.push(light);

            // Light pole
            const poleGeom = new THREE.CylinderGeometry(0.3, 0.5, 25, 8);
            const poleMat = new THREE.MeshStandardMaterial({ color: 0x444444, metalness: 0.8 });
            const pole = new THREE.Mesh(poleGeom, poleMat);
            pole.position.set(pos.x, 12.5, pos.z);
            pole.castShadow = true;
            this.scene.add(pole);

            // Light fixture
            const fixtureGeom = new THREE.BoxGeometry(3, 1.5, 2);
            const fixtureMat = new THREE.MeshStandardMaterial({ 
                color: 0xffffcc, 
                emissive: 0xffffcc,
                emissiveIntensity: 0.5
            });
            const fixture = new THREE.Mesh(fixtureGeom, fixtureMat);
            fixture.position.set(pos.x, 25, pos.z);
            this.scene.add(fixture);
        });
    }

    createField() {
        // Main grass field
        const fieldGeom = new THREE.PlaneGeometry(70, 100);
        const grassTexture = this.createGrassTexture();
        const fieldMat = new THREE.MeshStandardMaterial({ 
            map: grassTexture,
            roughness: 0.8,
            metalness: 0.1
        });
        const field = new THREE.Mesh(fieldGeom, fieldMat);
        field.rotation.x = -Math.PI / 2;
        field.position.y = 0;
        field.receiveShadow = true;
        this.scene.add(field);

        // Field lines
        this.createFieldLines();

        // Penalty area
        this.createPenaltyArea();
    }

    createGrassTexture() {
        const canvas = document.createElement('canvas');
        canvas.width = 512;
        canvas.height = 512;
        const ctx = canvas.getContext('2d');

        // Create striped grass pattern
        for (let i = 0; i < 16; i++) {
            ctx.fillStyle = i % 2 === 0 ? '#2d5a27' : '#358030';
            ctx.fillRect(0, i * 32, 512, 32);
        }

        // Add some noise
        const imageData = ctx.getImageData(0, 0, 512, 512);
        for (let i = 0; i < imageData.data.length; i += 4) {
            const noise = (Math.random() - 0.5) * 20;
            imageData.data[i] += noise;
            imageData.data[i + 1] += noise;
            imageData.data[i + 2] += noise;
        }
        ctx.putImageData(imageData, 0, 0);

        const texture = new THREE.CanvasTexture(canvas);
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;
        texture.repeat.set(2, 3);
        return texture;
    }

    createFieldLines() {
        const lineMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff });
        const lineHeight = 0.02;

        // Center circle
        const circleGeom = new THREE.RingGeometry(9, 9.3, 64);
        const circle = new THREE.Mesh(circleGeom, lineMaterial);
        circle.rotation.x = -Math.PI / 2;
        circle.position.y = 0.01;
        this.scene.add(circle);

        // Center spot
        const spotGeom = new THREE.CircleGeometry(0.3, 32);
        const spot = new THREE.Mesh(spotGeom, lineMaterial);
        spot.rotation.x = -Math.PI / 2;
        spot.position.y = 0.01;
        this.scene.add(spot);

        // Center line
        const centerLineGeom = new THREE.PlaneGeometry(70, 0.3);
        const centerLine = new THREE.Mesh(centerLineGeom, lineMaterial);
        centerLine.rotation.x = -Math.PI / 2;
        centerLine.position.y = 0.01;
        this.scene.add(centerLine);

        // Side lines
        const sideLineGeom = new THREE.PlaneGeometry(0.3, 100);
        [-34.85, 34.85].forEach(x => {
            const sideLine = new THREE.Mesh(sideLineGeom, lineMaterial);
            sideLine.rotation.x = -Math.PI / 2;
            sideLine.position.set(x, 0.01, 0);
            this.scene.add(sideLine);
        });

        // Goal lines
        const goalLineGeom = new THREE.PlaneGeometry(70, 0.3);
        [-49.85, 49.85].forEach(z => {
            const goalLine = new THREE.Mesh(goalLineGeom, lineMaterial);
            goalLine.rotation.x = -Math.PI / 2;
            goalLine.position.set(0, 0.01, z);
            this.scene.add(goalLine);
        });
    }

    createPenaltyArea() {
        const lineMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff });

        // Create penalty box for the far goal (where we shoot)
        const boxZ = -50;
        
        // Penalty area (large box)
        const penaltyWidth = 40;
        const penaltyDepth = 16;
        
        // Left line
        const leftLine = new THREE.Mesh(
            new THREE.PlaneGeometry(0.3, penaltyDepth),
            lineMaterial
        );
        leftLine.rotation.x = -Math.PI / 2;
        leftLine.position.set(-penaltyWidth/2, 0.01, boxZ + penaltyDepth/2);
        this.scene.add(leftLine);

        // Right line
        const rightLine = new THREE.Mesh(
            new THREE.PlaneGeometry(0.3, penaltyDepth),
            lineMaterial
        );
        rightLine.rotation.x = -Math.PI / 2;
        rightLine.position.set(penaltyWidth/2, 0.01, boxZ + penaltyDepth/2);
        this.scene.add(rightLine);

        // Front line
        const frontLine = new THREE.Mesh(
            new THREE.PlaneGeometry(penaltyWidth, 0.3),
            lineMaterial
        );
        frontLine.rotation.x = -Math.PI / 2;
        frontLine.position.set(0, 0.01, boxZ + penaltyDepth);
        this.scene.add(frontLine);

        // Goal area (small box)
        const goalAreaWidth = 18;
        const goalAreaDepth = 5.5;

        const smallLeftLine = new THREE.Mesh(
            new THREE.PlaneGeometry(0.3, goalAreaDepth),
            lineMaterial
        );
        smallLeftLine.rotation.x = -Math.PI / 2;
        smallLeftLine.position.set(-goalAreaWidth/2, 0.01, boxZ + goalAreaDepth/2);
        this.scene.add(smallLeftLine);

        const smallRightLine = new THREE.Mesh(
            new THREE.PlaneGeometry(0.3, goalAreaDepth),
            lineMaterial
        );
        smallRightLine.rotation.x = -Math.PI / 2;
        smallRightLine.position.set(goalAreaWidth/2, 0.01, boxZ + goalAreaDepth/2);
        this.scene.add(smallRightLine);

        const smallFrontLine = new THREE.Mesh(
            new THREE.PlaneGeometry(goalAreaWidth, 0.3),
            lineMaterial
        );
        smallFrontLine.rotation.x = -Math.PI / 2;
        smallFrontLine.position.set(0, 0.01, boxZ + goalAreaDepth);
        this.scene.add(smallFrontLine);

        // Penalty spot
        const penaltySpot = new THREE.Mesh(
            new THREE.CircleGeometry(0.25, 32),
            lineMaterial
        );
        penaltySpot.rotation.x = -Math.PI / 2;
        penaltySpot.position.set(0, 0.01, boxZ + 11);
        this.scene.add(penaltySpot);

        // Penalty arc
        const arcGeom = new THREE.RingGeometry(9, 9.3, 32, 1, Math.PI * 0.7, Math.PI * 0.6);
        const arc = new THREE.Mesh(arcGeom, lineMaterial);
        arc.rotation.x = -Math.PI / 2;
        arc.rotation.z = Math.PI / 2;
        arc.position.set(0, 0.01, boxZ + penaltyDepth);
        this.scene.add(arc);
    }

    createGoal() {
        const goalWidth = 7.32;
        const goalHeight = 2.44;
        const goalDepth = 2;
        const postRadius = 0.1;
        const goalZ = -49;

        const postMaterial = new THREE.MeshStandardMaterial({ 
            color: 0xffffff,
            metalness: 0.3,
            roughness: 0.5
        });

        // Left post
        const leftPostGeom = new THREE.CylinderGeometry(postRadius, postRadius, goalHeight, 16);
        const leftPost = new THREE.Mesh(leftPostGeom, postMaterial);
        leftPost.position.set(-goalWidth/2, goalHeight/2, goalZ);
        leftPost.castShadow = true;
        this.scene.add(leftPost);

        // Right post
        const rightPost = new THREE.Mesh(leftPostGeom, postMaterial);
        rightPost.position.set(goalWidth/2, goalHeight/2, goalZ);
        rightPost.castShadow = true;
        this.scene.add(rightPost);

        // Crossbar
        const crossbarGeom = new THREE.CylinderGeometry(postRadius, postRadius, goalWidth + postRadius * 2, 16);
        const crossbar = new THREE.Mesh(crossbarGeom, postMaterial);
        crossbar.rotation.z = Math.PI / 2;
        crossbar.position.set(0, goalHeight, goalZ);
        crossbar.castShadow = true;
        this.scene.add(crossbar);

        // Net
        this.createNet(goalWidth, goalHeight, goalDepth, goalZ);

        // Back posts
        const backLeftPost = new THREE.Mesh(
            new THREE.CylinderGeometry(postRadius * 0.7, postRadius * 0.7, goalHeight, 8),
            postMaterial
        );
        backLeftPost.position.set(-goalWidth/2, goalHeight/2, goalZ - goalDepth);
        this.scene.add(backLeftPost);

        const backRightPost = new THREE.Mesh(
            new THREE.CylinderGeometry(postRadius * 0.7, postRadius * 0.7, goalHeight, 8),
            postMaterial
        );
        backRightPost.position.set(goalWidth/2, goalHeight/2, goalZ - goalDepth);
        this.scene.add(backRightPost);
    }

    createNet(width, height, depth, z) {
        const netMaterial = new THREE.MeshBasicMaterial({ 
            color: 0xffffff,
            wireframe: true,
            transparent: true,
            opacity: 0.5
        });

        // Back net
        const backNetGeom = new THREE.PlaneGeometry(width, height, 20, 8);
        const backNet = new THREE.Mesh(backNetGeom, netMaterial);
        backNet.position.set(0, height/2, z - depth);
        this.scene.add(backNet);

        // Left side net
        const sideNetGeom = new THREE.PlaneGeometry(depth, height, 6, 8);
        const leftNet = new THREE.Mesh(sideNetGeom, netMaterial);
        leftNet.rotation.y = Math.PI / 2;
        leftNet.position.set(-width/2, height/2, z - depth/2);
        this.scene.add(leftNet);

        // Right side net
        const rightNet = new THREE.Mesh(sideNetGeom, netMaterial);
        rightNet.rotation.y = -Math.PI / 2;
        rightNet.position.set(width/2, height/2, z - depth/2);
        this.scene.add(rightNet);

        // Top net
        const topNetGeom = new THREE.PlaneGeometry(width, depth, 20, 6);
        const topNet = new THREE.Mesh(topNetGeom, netMaterial);
        topNet.rotation.x = Math.PI / 2;
        topNet.position.set(0, height, z - depth/2);
        this.scene.add(topNet);

        this.goalNet = { back: backNet, left: leftNet, right: rightNet, top: topNet };
    }

    createBall() {
        // Football (soccer ball)
        const ballGeom = new THREE.SphereGeometry(0.35, 32, 32);
        
        // Create soccer ball texture
        const ballTexture = this.createBallTexture();
        
        const ballMat = new THREE.MeshStandardMaterial({ 
            map: ballTexture,
            roughness: 0.4,
            metalness: 0.1
        });
        
        this.ball = new THREE.Mesh(ballGeom, ballMat);
        this.ball.position.set(0, 0.35, 0);
        this.ball.castShadow = true;
        this.scene.add(this.ball);

        // Ball initial position for shooting
        this.ballStartPos = new THREE.Vector3(0, 0.35, 0);
        this.ballGoalPos = new THREE.Vector3(0, 1.2, -48);
    }

    createBallTexture() {
        const canvas = document.createElement('canvas');
        canvas.width = 256;
        canvas.height = 256;
        const ctx = canvas.getContext('2d');

        // White base
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, 256, 256);

        // Draw black pentagons pattern
        ctx.fillStyle = '#222222';
        const centers = [
            [128, 60], [60, 128], [196, 128], [90, 200], [166, 200]
        ];
        
        centers.forEach(([x, y]) => {
            ctx.beginPath();
            for (let i = 0; i < 5; i++) {
                const angle = (i * 2 * Math.PI / 5) - Math.PI / 2;
                const px = x + 30 * Math.cos(angle);
                const py = y + 30 * Math.sin(angle);
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();
            ctx.fill();
        });

        const texture = new THREE.CanvasTexture(canvas);
        return texture;
    }

    createGoalkeeper() {
        // Simple goalkeeper figure
        const gkGroup = new THREE.Group();

        // Body
        const bodyGeom = new THREE.CapsuleGeometry(0.4, 1.2, 8, 16);
        const bodyMat = new THREE.MeshStandardMaterial({ color: 0xff6600 }); // Orange goalkeeper jersey
        const body = new THREE.Mesh(bodyGeom, bodyMat);
        body.position.y = 1.2;
        gkGroup.add(body);

        // Head
        const headGeom = new THREE.SphereGeometry(0.25, 16, 16);
        const headMat = new THREE.MeshStandardMaterial({ color: 0xffcc99 });
        const head = new THREE.Mesh(headGeom, headMat);
        head.position.y = 2.1;
        gkGroup.add(head);

        // Arms
        const armGeom = new THREE.CapsuleGeometry(0.12, 0.7, 8, 8);
        const armMat = new THREE.MeshStandardMaterial({ color: 0xff6600 });
        
        const leftArm = new THREE.Mesh(armGeom, armMat);
        leftArm.position.set(-0.6, 1.5, 0);
        leftArm.rotation.z = Math.PI / 4;
        gkGroup.add(leftArm);

        const rightArm = new THREE.Mesh(armGeom, armMat);
        rightArm.position.set(0.6, 1.5, 0);
        rightArm.rotation.z = -Math.PI / 4;
        gkGroup.add(rightArm);

        // Gloves
        const gloveGeom = new THREE.SphereGeometry(0.18, 8, 8);
        const gloveMat = new THREE.MeshStandardMaterial({ color: 0x00ff00 });
        
        const leftGlove = new THREE.Mesh(gloveGeom, gloveMat);
        leftGlove.position.set(-1, 1.9, 0);
        gkGroup.add(leftGlove);

        const rightGlove = new THREE.Mesh(gloveGeom, gloveMat);
        rightGlove.position.set(1, 1.9, 0);
        gkGroup.add(rightGlove);

        // Legs
        const legGeom = new THREE.CapsuleGeometry(0.15, 0.6, 8, 8);
        const legMat = new THREE.MeshStandardMaterial({ color: 0x222222 });
        
        const leftLeg = new THREE.Mesh(legGeom, legMat);
        leftLeg.position.set(-0.2, 0.4, 0);
        gkGroup.add(leftLeg);

        const rightLeg = new THREE.Mesh(legGeom, legMat);
        rightLeg.position.set(0.2, 0.4, 0);
        gkGroup.add(rightLeg);

        gkGroup.position.set(0, 0, -47);
        gkGroup.castShadow = true;
        
        this.goalkeeper = gkGroup;
        this.scene.add(gkGroup);
    }

    createStadium() {
        // Stadium stands
        const standMaterial = new THREE.MeshStandardMaterial({ color: 0x333344 });
        
        // Back stand (behind goal)
        const backStand = new THREE.Mesh(
            new THREE.BoxGeometry(80, 15, 10),
            standMaterial
        );
        backStand.position.set(0, 7.5, -60);
        this.scene.add(backStand);

        // Front stand (behind camera)
        const frontStand = new THREE.Mesh(
            new THREE.BoxGeometry(80, 10, 10),
            standMaterial
        );
        frontStand.position.set(0, 5, 55);
        this.scene.add(frontStand);

        // Side stands
        const sideStandGeom = new THREE.BoxGeometry(10, 12, 120);
        
        const leftStand = new THREE.Mesh(sideStandGeom, standMaterial);
        leftStand.position.set(-45, 6, 0);
        this.scene.add(leftStand);

        const rightStand = new THREE.Mesh(sideStandGeom, standMaterial);
        rightStand.position.set(45, 6, 0);
        this.scene.add(rightStand);
    }

    createCrowd() {
        // Simplified crowd as colored dots on the stands
        const crowdColors = [0xff0000, 0x0000ff, 0xffff00, 0xffffff, 0xff6600];
        
        const createCrowdSection = (xMin, xMax, yMin, yMax, z, zDir = 1) => {
            for (let i = 0; i < 200; i++) {
                const color = crowdColors[Math.floor(Math.random() * crowdColors.length)];
                const geo = new THREE.SphereGeometry(0.3, 8, 8);
                const mat = new THREE.MeshBasicMaterial({ color });
                const person = new THREE.Mesh(geo, mat);
                
                person.position.set(
                    xMin + Math.random() * (xMax - xMin),
                    yMin + Math.random() * (yMax - yMin),
                    z + (Math.random() * 5 * zDir)
                );
                this.scene.add(person);
            }
        };

        // Back stand crowd
        createCrowdSection(-35, 35, 8, 14, -58, -1);
        
        // Side stand crowds
        createCrowdSection(-44, -41, 4, 10, -45, 1);
        createCrowdSection(-44, -41, 4, 10, 45, 1);
        createCrowdSection(41, 44, 4, 10, -45, 1);
        createCrowdSection(41, 44, 4, 10, 45, 1);
    }

    createAtmosphere() {
        // Add some floating particles for atmosphere
        const particleGeom = new THREE.BufferGeometry();
        const particleCount = 500;
        const positions = new Float32Array(particleCount * 3);

        for (let i = 0; i < particleCount * 3; i += 3) {
            positions[i] = (Math.random() - 0.5) * 100;
            positions[i + 1] = Math.random() * 30;
            positions[i + 2] = (Math.random() - 0.5) * 100;
        }

        particleGeom.setAttribute('position', new THREE.BufferAttribute(positions, 3));

        const particleMat = new THREE.PointsMaterial({
            color: 0xffffee,
            size: 0.1,
            transparent: true,
            opacity: 0.5
        });

        const particles = new THREE.Points(particleGeom, particleMat);
        this.scene.add(particles);
        this.atmosphereParticles = particles;
    }

    shootBall(isGoal) {
        if (this.isAnimatingBall) return;
        this.isAnimatingBall = true;

        const startPos = this.ball.position.clone();
        const targetX = isGoal ? (Math.random() - 0.5) * 4 : (Math.random() > 0.5 ? 5 : -5);
        const targetY = isGoal ? 0.5 + Math.random() * 1.5 : 3 + Math.random() * 2;
        const targetZ = -48;

        const duration = 1000;
        const startTime = Date.now();

        // Move goalkeeper
        if (!isGoal) {
            this.moveGoalkeeper(targetX);
        } else {
            // Goalkeeper dives wrong way
            this.moveGoalkeeper(targetX > 0 ? -2 : 2);
        }

        const animateBall = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            // Ease out cubic
            const easeProgress = 1 - Math.pow(1 - progress, 3);

            // Calculate position with arc
            this.ball.position.x = startPos.x + (targetX - startPos.x) * easeProgress;
            this.ball.position.z = startPos.z + (targetZ - startPos.z) * easeProgress;
            
            // Parabolic arc for height
            const arcHeight = 3;
            this.ball.position.y = startPos.y + arcHeight * Math.sin(progress * Math.PI) + (targetY - startPos.y) * progress;

            // Rotate ball
            this.ball.rotation.x += 0.3;
            this.ball.rotation.y += 0.1;

            if (progress < 1) {
                requestAnimationFrame(animateBall);
            } else {
                // Ball reached target
                if (isGoal) {
                    this.celebrateGoal();
                } else {
                    this.showMiss();
                }
                
                // Reset ball after delay
                setTimeout(() => {
                    this.resetBall();
                    this.resetGoalkeeper();
                    this.isAnimatingBall = false;
                }, 1500);
            }
        };

        animateBall();
    }

    moveGoalkeeper(targetX) {
        const startX = this.goalkeeper.position.x;
        const duration = 600;
        const startTime = Date.now();

        const animateGK = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easeProgress = 1 - Math.pow(1 - progress, 2);

            this.goalkeeper.position.x = startX + (targetX * 1.5 - startX) * easeProgress;
            
            // Diving animation
            if (progress > 0.3) {
                this.goalkeeper.rotation.z = (targetX > 0 ? -1 : 1) * Math.PI / 4 * ((progress - 0.3) / 0.7);
            }

            if (progress < 1) {
                requestAnimationFrame(animateGK);
            }
        };

        animateGK();
    }

    resetGoalkeeper() {
        const duration = 500;
        const startTime = Date.now();
        const startX = this.goalkeeper.position.x;
        const startRot = this.goalkeeper.rotation.z;

        const animate = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);

            this.goalkeeper.position.x = startX * (1 - progress);
            this.goalkeeper.rotation.z = startRot * (1 - progress);

            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };

        animate();
    }

    resetBall() {
        const duration = 500;
        const startTime = Date.now();
        const startPos = this.ball.position.clone();

        const animate = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easeProgress = progress * progress;

            this.ball.position.lerpVectors(startPos, this.ballStartPos, easeProgress);
            this.ball.rotation.set(0, 0, 0);

            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };

        animate();
    }

    celebrateGoal() {
        // Create confetti particles
        const colors = [0xffd700, 0xff0000, 0x00ff00, 0x0000ff, 0xff00ff];
        
        for (let i = 0; i < 100; i++) {
            const geo = new THREE.BoxGeometry(0.2, 0.2, 0.02);
            const mat = new THREE.MeshBasicMaterial({ 
                color: colors[Math.floor(Math.random() * colors.length)],
                side: THREE.DoubleSide
            });
            const confetti = new THREE.Mesh(geo, mat);
            
            confetti.position.set(
                (Math.random() - 0.5) * 10,
                5 + Math.random() * 5,
                -45
            );
            
            confetti.userData = {
                velocity: new THREE.Vector3(
                    (Math.random() - 0.5) * 0.3,
                    Math.random() * 0.2,
                    (Math.random() - 0.5) * 0.3
                ),
                rotSpeed: new THREE.Vector3(
                    Math.random() * 0.2,
                    Math.random() * 0.2,
                    Math.random() * 0.2
                )
            };
            
            this.scene.add(confetti);
            this.particles.push(confetti);
        }

        // Flash effect
        this.flashScreen(0x00ff00);
    }

    showMiss() {
        // Red flash
        this.flashScreen(0xff0000);
    }

    flashScreen(color) {
        const flashGeo = new THREE.PlaneGeometry(200, 200);
        const flashMat = new THREE.MeshBasicMaterial({ 
            color: color,
            transparent: true,
            opacity: 0.3,
            side: THREE.DoubleSide
        });
        const flash = new THREE.Mesh(flashGeo, flashMat);
        flash.position.copy(this.camera.position);
        flash.position.z -= 5;
        flash.lookAt(this.camera.position);
        this.scene.add(flash);

        const startTime = Date.now();
        const animateFlash = () => {
            const elapsed = Date.now() - startTime;
            const progress = elapsed / 500;
            
            flashMat.opacity = 0.3 * (1 - progress);
            
            if (progress < 1) {
                requestAnimationFrame(animateFlash);
            } else {
                this.scene.remove(flash);
            }
        };
        animateFlash();
    }

    onResize() {
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(window.innerWidth, window.innerHeight);
    }

    animate() {
        requestAnimationFrame(() => this.animate());

        const delta = this.clock.getDelta();

        // Update controls
        this.controls.update();

        // Animate confetti particles
        for (let i = this.particles.length - 1; i >= 0; i--) {
            const p = this.particles[i];
            p.position.add(p.userData.velocity);
            p.userData.velocity.y -= 0.01; // Gravity
            p.rotation.x += p.userData.rotSpeed.x;
            p.rotation.y += p.userData.rotSpeed.y;
            p.rotation.z += p.userData.rotSpeed.z;

            // Remove if below ground
            if (p.position.y < 0) {
                this.scene.remove(p);
                this.particles.splice(i, 1);
            }
        }

        // Subtle ball idle animation
        if (!this.isAnimatingBall) {
            this.ball.rotation.y += 0.01;
        }

        // Animate atmosphere particles
        if (this.atmosphereParticles) {
            this.atmosphereParticles.rotation.y += 0.0002;
        }

        this.renderer.render(this.scene, this.camera);
    }

    // Camera positions for different game states
    setCameraForMenu() {
        this.animateCamera(new THREE.Vector3(0, 30, 50), new THREE.Vector3(0, 0, -10));
    }

    setCameraForGame() {
        this.animateCamera(new THREE.Vector3(0, 8, 20), new THREE.Vector3(0, 1, -30));
    }

    setCameraForResult() {
        this.animateCamera(new THREE.Vector3(0, 5, -35), new THREE.Vector3(0, 1, -48));
    }

    animateCamera(targetPos, targetLookAt) {
        const startPos = this.camera.position.clone();
        const startTarget = this.controls.target.clone();
        const duration = 1500;
        const startTime = Date.now();

        const animate = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easeProgress = 1 - Math.pow(1 - progress, 3);

            this.camera.position.lerpVectors(startPos, targetPos, easeProgress);
            this.controls.target.lerpVectors(startTarget, targetLookAt, easeProgress);

            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };

        animate();
    }
}

// Initialize 3D scene
let stadium3D;
window.addEventListener('DOMContentLoaded', () => {
    stadium3D = new Stadium3D();
});

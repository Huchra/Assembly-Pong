pong.model small
.386
.stack 64
.data

	widthScreen            DW                 139h
	heightScreen           dw                 0C8h
	;window resolution (Variable to change in final, depends on display mode)

	CenterX                dw                 09Eh                                    	;X position of screen center for ball centering
	CenterY                dw                 64h                                     	;Y position of screen center for ball centering

	BallX                  dw                 0A0h                                    	;current X of eBall (per frame)
	BallY                  dw                 64h                                     	;current Y of Ball (per frame)
	CurrentTime            db                 0
	BallSize               dw                 05h                                     	;size of ball (3*3 = 9 PIXELS)
	BallColor              Db                 0Fh                                     	;define ball color for powerups (default white)
	VelocityX              DW                 01h                                     	;Ball velocity in X direction
	VelocityY              DW                 00h                                     	;Ball velocity in Y direction
	ResetFlag              DW                 00                                      	;Checks that a point has been scored (to resume physics)
	DirectionFlag          dw                 01

	DefaultVelocity        DW                 02                                      	;Ball Velocity after being reset
	MaxVelocity            DW                 0Ah                                     	;Max velocity the ball is allowed to reach (for proper collision to occur)

	LeftPaddle_X           dw                 10h                                     	;current X of left Paddle (should be const throughout game)
	RightPaddle_x          dw                 128h                                    	;current X of right Paddle (should be const throughout game)
	LeftPaddle_Y           dw                 5Bh                                     	;Current Y of Left Paddle (per frame)
	RightPaddle_Y          dw                 5Bh                                     	;Current Y of Right Paddle (per frame)
	PaddleDefaultY         dw                 5bh                                     	;Y co-ordinate for resetting the paddle
	                       LeftCollisionFlag  db, 00h                                 	;eEnsures that the Paddle Collides once with the left paddle
	                       RightCollisionFlag db, 00h                                 	;Ensures that teh Paddle Collides once with the right paddle
	Paddlewidth            dw                 09h                                     	;Paddle width in pxels for drawing
	PaddleHeight           dw                 22h                                     	;Paddle height in pixels for drawing and collision calculations
	LeftPaddleColor        db                 0Fh                                     	;define paddle color for powerups (default white)
	RightPaddleColor       db                 0Fh                                     	;define paddle color for powerups (default white)

	RightPaddleMoveSpeed   DW                 0Ch                                     	;Right Paddle Move speed (kept seperate for powerups)
	LeftPaddleMoveSpeed    DW                 0Ch                                     	;Left Paddle Move speed (kept seperate for powerups)
	DefaultPaddleMoveSpeed DW                 0Ch
	StartUpText            db                 "Press E to start a 2 player game"
	StartUpText1           db                 "Press V to send a chat invitation"
	StartUpText2           db                 "Press ESC to exit"
	;Text that appears in main menu
	Player1Score           dw                 30h
	Player2Score           dw                 30h

	EndTextP1              db                 "Player1 has won, press N to play again"
	EndTextP2              db                 "Player2 has won, press N to play again"
	NewGame                dw                 0

	RandomNumber           db                 ?                                       	;Random number used to check for powerup spawning

	DrawPowerUpX           dw                 ?                                       	;X position to draw a powerup
	DrawPowerUpY           dw                 ?                                       	;Y position to draw a powerup
	PowerUpSizeX           dw                 05h                                     	;PowerUp size for collisions
	PowerUpSizeY           dw                 0Ah                                     	;PowerUp size for collisions
	ActivePowerUpFlag      db                 0                                       	;Checks that a powerup is active
PowerUpColor db 0fh                         ;Power ColorUP for drawing
.code

	;Randomizes Ball Angle
BallAngle proc near
	                            mov  ah, 2Ch
	                            int  21h                        	;Take system time
	                            xor  ah, ah                     	;ah = 0
	                            mov  bh, dh                     	;set up the division
	                            mov  dh, 5
	                            mov  al, bh
	                            div  dh
	                            cmp  ah, 00h                    	;Check the remainder for the angle
	                            JE   AngleFortyFive
	                            CMP  ah, 1
	                            JE   AngleZero
	                            CMP  ah, 2
	                            JE   AngleThirty
	                            CMP  ah, 3
	                            JE   AngleNegativeThirty
	                            JMP  AngleNegativeFortyFive
    
	AngleFortyFive:             
	                            mov  ax, 3
	                            mov  velocityX, ax
	                            mov  velocityY, ax
	                            JMP  CheckDirection

	AngleZero:                  
	                            mov  ax, 3
	                            mov  velocityX, ax
	                            JMP  CheckDirection

	AngleNegativeFortyFive:     
	                            mov  ax, 3
	                            mov  velocityY, ax
	                            neg  velocityY
	                            mov  velocityX, ax
	                            JMP  CheckDirection

	AngleThirty:                
	                            mov  ax, 4
	                            mov  velocityX, ax
	                            mov  ax, 3
	                            mov  velocityY, ax
	                            JMP  CheckDirection

	AngleNegativeThirty:        
	                            mov  ax, 4
	                            mov  VelocityX, AX
	                            mov  ax, 3
	                            mov  VelocityY, ax
	                            neg  VelocityY
	                            JMP  CheckDirection


	CheckDirection:             
	                            mov  ax, 1
	                            CMP  DirectionFlag, ax
	                            JE   nochange
	                            neg  VelocityX
	nochange:                   
	                            RET
BallAngle endp

GenerateRand proc near
	                            mov  ah, 0
	                            int  1ah                        	;interrupt to get clock ticks since midnight

	                            mov  ax, dx
	                            mov  dx, 0
	                            mov  cx, 10
	                            div  cx                         	;div by 10 and dl contains remainder of division (0 - 9)

	                            mov  RandomNumber, dl           	;move random number to a variable for storage

	                            mov  ah, 0
	                            int  1ah

	                            mov  ax, dx
	                            mov  dx, 0
	                            mov  cx, 81d
	                            div  cx
    
	                            mov  DrawPowerUpX,  dx
	                            add  DrawPowerUpX, 160d
	                            mov  DrawPowerUpY, dx
	                            add  DrawPowerUpY, 80d

	                            RET
GenerateRand endp
	;Start Menu
StartMenu proc near
	                            mov  al, 13h
	                            mov  ah, 0
	                            int  10h
	                            mov  si, @data
	                            mov  ah, 13h
	                            mov  al, 0
	                            mov  bh, 0
	                            mov  bl, 0fh
	                            mov  cx, 32d                    	; Number of characters in the string to be displayed
	                            mov  dh, 12
	                            mov  dl, 3
	                            mov  es, si
	                            mov  bp, offset StartUpText
	                            int  10H
	                            mov  cx, 33d                    	; Number of characters in the string to be displayed
	                            mov  dh,8                       	; Coloumn no
	                            mov  dl,3                       	; Row no
	                            mov  bp, offset startuptext1
	                            int  10H
	                            mov  cx, 17d                    	; Number of characters in the string to be displayed
	                            mov  dh,16
	                            mov  dl,3
	                            mov  bp, offset startuptext2
	                            int  10H
	retry:                      
	                            mov  ah, 0
	                            int  16h
	                            cmp  al, 45h                    	; compare the input to the letter 'E', and if found equal then start the game
	                            JE   startgame
	                            CMP  al, 65h                    	; Compare the input tp the letter 'e', same function
	                            JE   startgame
	                            cmp  al,86d                     	; Compare the input tp the letter 'V', and if found equal then start the chat mode
	                            jE   ChatMode
	                            cmp  al,118d                    	; Compare the input tp the letter 'v', same function
	                            jE   ChatMode
	                            cmp  al,27d                     	; Compare the input to escape , exits if so
	                            jE   EscapePressed
	                            JMP  retry
	startgame:                  
	                            ret
StartMenu endp
	;End Menu when a player scores 10 points
EndMenu proc near
	                            CMP  Player1Score, 3AH
	                            JGE  CheckWin
	                            CMP  Player2Score, 3AH
	                            JGE  CheckWin
	                            JMP  NoWin
	CheckWin:                   
	                            Call clearscreen
	                            mov  si, @data
	                            mov  ah, 13h
	                            mov  al, 0
	                            mov  bh, 0h
	                            mov  bl, 0fh
	                            mov  cx, 38d
	                            mov  dh, 3
	                            mov  dl, 1
	                            mov  es, si
	                            CMP  Player1Score, 3AH
	                            JGE  Player1Win
	                            CMP  Player2Score, 3AH
	                            JGE  Player2Win
	Player1Win:                 
	                            mov  bp, offset EndTextP1
	                            int  10H
	retr_y:                     
	                            mov  ah, 0
	                            int  16h
	                            CMP  al, 6eh
	                            JE   NewGamee
	                            CMP  al, 4Eh
	                            JE   NewGamee
	                            JMP  retr_y
	NewGamee:                   
	                            mov  ax, 1
	                            mov  NewGame, ax
	                            ret
	Player2Win:                 
	                            mov  bp, offset EndTextP2
	                            int  10H
	retr_yy:                    
	                            mov  ah, 0
	                            int  16h
	                            CMP  al, 6eh
	                            JE   NewGame2
	                            CMP  al, 4Eh
	                            JE   NewGame2
	                            JMP  retr_yy
	NewGame2:                   
	                            mov  ax, 1
	                            mov  NewGame, ax
	                            ret
EndMenu endp
	;reads player score from data segment then prints it to play screenت
UpdatePlayerScores proc near
	                            mov  al, 13h
	                            mov  ah, 0
	                            int  10H
	                            mov  si, @data
	                            mov  ah, 13h
	                            mov  al, 0
	                            mov  bh, 0
	                            mov  bl, 0fh
	                            mov  cx, 1
	                            mov  dh, 2
	                            mov  dl, 13
	                            mov  es, si
	                            mov  bp, offset Player1Score
	                            int  10H

	                            mov  dl, 26
	                            mov  dh, 2
	                            mov  cx, 1
	                            mov  bp, offset Player2Score
	                            int  10H

	                            RET
	Nowin:                      
	                            Ret
UpdatePlayerScores endp

	;clears screen to redraw each frame
clearscreen proc near
	                            mov  ah, 0h                     	;set video mode
	                            mov  al, 13h                    	;set color mode
	                            int  10h
    

	                            mov  ah, 0bh
	                            mov  bh, 00h
	                            mov  bl, 00h                    	;background color
	                            int  10h
	;set background and border config

	                            ret
clearscreen endp


DrawMidHorizontalLine proc near
	                            mov  dx,64h
	                            mov  cx,0

	LoopDrawLine:               
	                            mov  ah, 0ch
	                             mov  al, 08h
	                            mov  bh, 00Ah
	                            int  10H
                                
	                            add  cx,3
	                            cmp  cx,widthScreen
	                            jl   LoopDrawLine

	                            ret
DrawMidHorizontalLine endp


WriteStringUntilEnter proc near
	BeginningOfChat:            
	                            MOV  DI,1000d
	                            MOV  AH,01H
	LOOPUntilEnter:             
	                            cmp  di,1480d
	                            jg   EndOfTheAvailableTypingArea
	                            INT  21H
	                            CMP  AL,0DH                     	;compare with the ascii code for Enter
	                            JE   EnterPressed
	                            MOV  [DI],AL
	                            INC  DI
	                            JMP  LOOPUntilEnter

	EnterPressed:               
	                            mov  bh,ah
	                            mov  ax,di
	                            add  di,80d
	                            mov  dx,13
	                            mov  ah,2
	                            int  21h
	                            mov  dx,10
	                            mov  ah,2
	                            int  21h
	                            mov  ah,bh
	                            jmp  LOOPUntilEnter             	; the above code skips a line happens when enter is pressed

	EndOfTheAvailableTypingArea:
	                            call clearscreen
	                            call DrawMidHorizontalLine
	;MOV AH,4CH
	;INT 21H
	                            jmp  BeginningOfChat

	                            ret
WriteStringUntilEnter endp



ChatMode proc near
	                            call clearscreen
	                            call DrawMidHorizontalLine
	                            call WriteStringUntilEnter
	                            ret
ChatMode endp






	;calculates ball position for drawing
move proc near                                              		;calculates ball x and y position in the next step (velocity)
	                            mov  ax, VelocityX
	                            add  BallX, ax                  	;calulacte X velocity
    
	                            CMP  BallX, 01h                 	;check that the Ball is not at the left border of the screen  X
	                            JLE  resetpos

	                            mov  ax, widthScreen
	                            sub  ax, BallSize               	; AX = WidthScreen - Ballsize, so that the ball doesn't wrap around
	                            CMP  BallX, ax                  	;check that the Ball is not at the right border of the screen  X
	                            JGE  resetpos

   
    
	                            mov  ax, VelocityY              	;calculate Y velocity
	                            add  BallY, ax

	                            CMP  BallY, 0                   	;check that the ball is not at the Top of the screen
	                            JLE  NegVelY

	                            mov  ax, heightScreen
	                            sub  ax, BallSize
	                            CMP  BallY, ax
	;check that the ball is not at the bottom of the screen
	                            JGE  NegVelY
	;collision checking
	                            mov  ax, BallX                  	;check left paddle collision
	                            add  ax, BallSize               	;using a square as the collision/ hitbox of each entity (using aabb model from https://tinyurl.com/p8e787x)
	                            CMP  ax, LeftPaddle_X           	;(BallX + BallSize) > (LeftPaddle_X)
	                            JNG  CheckRightCol

	                            mov  ax, LeftPaddle_X
	                            add  ax, Paddlewidth
	                            CMP  BallX, ax                  	;BallX < (LeftPaddle_X + PaddleWidth)
	                            JNL  CheckRightCol

	                            mov  ax, BallY
	                            add  ax, BallSize
	                            CMP  ax, leftPaddle_y           	;(BallY + BallSize) > (LeftPaddle_Y)
	                            JNG  CheckRightCol
    
	                            mov  ax, leftPaddle_y
	                            add  ax, PaddleHeight
	                            CMP  BallY, ax                  	;BallY < (LeftPaddle_Y + PaddleHeight)
	                            JNL  CheckRightCol
    
	                            CMP  LeftCollisionFlag, 0
	                            JNE  noCol

    
    
	                            Call ReflectionLeft
	                            CMP  ActivePowerUpFlag, 0
	                            JNE  ContinueLeft
	                            Call GenerateRand
   
	ContinueLeft:               
	                            RET

	NegVelY:                    
	                            Neg  VelocityY                  	;VelocityY = -VelocityY --> switches direction of ball
	                            ret

	resetpos:                   
	                            Call BallPosReset               	;reset ball to center of screen
	                            ret
	;check right paddle collision (similar to left paddle)
	CheckRightCol:              
	                            mov  ax, BallX
	                            add  ax, BallSize
	                            cmp  ax, RightPaddle_X
	                            JNG  noCol

	                            mov  ax, RightPaddle_X
	                            add  ax, Paddlewidth
	                            CMP  BallX, ax
	                            jnl  noCol

	                            mov  ax, BallY
	                            add  ax, BallSize
	                            CMP  AX, RightPaddle_Y
	                            JNG  noCol

	                            mov  ax, RightPaddle_Y
	                            add  ax, PaddleHeight
	                            cmp  BallY, ax
	                            JNL  noCol

	                            CMP  RightCollisionFlag, 0
	                            JNE  noCol
                                               
	;collision occured
	                            Call ReflectionRight
	                            CMP  ActivePowerUpFlag, 0
	                            JNE  ContinueRight
	                            Call GenerateRand
    
	ContinueRight:              
	                            RET

	noCol:                                                      	;Recenters Ball in the middle of screen
	                            ret

move endp

	;draws the midline of the playing screen
MidScreenDivider proc near
	                            mov  cx, 0A0h
	                            mov  dx, 00

	DrawScreenDivider:          
	                            mov  ah, 0ch
	                            mov  al, 08h
	                            mov  bh, 00Ah
	                            int  10H
	;sets video mode and a pixel color of dark grey
	                            add  dx, 6
	                            mov  ax, dx
	                            sub  ax, heightScreen
	                            cmp  ax, 0
	                            JNG  DrawScreenDivider
	;draws a pixel every 6 pixels
	                            RET



MidScreenDivider endp
	;instructions for the right paddle's physics post collision
ReflectionRight proc near
	                            mov  LeftCollisionFlag, 00      	;Zero the Left Collision flag
	                            inc  RightCollisionFlag         	;Incremnt its own collision flag

	                            CMP  velocityY, 0               	;Checks that the angle of incidence is zero
	                            JE   IncidenceZeroRight

	                            mov  ax, BallSize
	                            shr  ax, 1
	                            add  ax, BallY                  	;Calculates Ball Center in Y
	                            mov  bx, PaddleHeight
	                            shr  bx, 1
	                            add  bx, RightPaddle_Y          	;Calculates Paddle Center in Y
	                            CMP  ax, bx
	                            JE   PerfectReflectionRight     	;If the ball hits paddle center, mirror reflection

	                            mov  ax, velocityX
	                            sub  ax, VelocityY
	                            CMP  ax, 1
	                            JE   Incidence30Right
	                            CMP  ax, 0
	                            JE   IncidencePos45Right
	                            mov  ax, VelocityY
	                            CMP  ax, 0
	                            JL   NegativeYAngleRight

	NegativeYAngleRight:                                        	;Negates Y value such that previous calculations are still correct
	                            Neg  velocityY
	                            mov  ax, VelocityX
	                            sub  ax, VelocityY
	                            CMP  ax, 1
	                            JE   Incidence30Right
	                            CMP  ax, 0
	                            JE   IncidenceNegative45Right


	IncidenceZeroRight:         
	                            mov  ax, BallSize
	                            shr  ax, 1
	                            add  ax, BallY                  	;Calculates Ball center in Y
	                            mov  bx, PaddleHeight
	                            shr  bx, 1
	                            add  bx, RightPaddle_Y          	;Calculates Paddle Center in Y
	                            cmp  ax, bx
	                            JE   ZeroReflectionRight        	;If they are both the same, then the ball hit the center and the collision has a reflection angle of zero
	                            CMP  ax, bx
	                            JG   Neg45ReflectionRight       	;If it hits the lower part of the paddle, it reflects downwards
	                            CMP  ax, bx
	                            JL   Pos45ReflectionRight       	;If it hits the upper part of the paddle, it reflects upwards.
	                            JMP  noColRight

	ZeroReflectionRight:        
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax              	;check that the ball velocity is not above max allowed for proper physics
	                            JG   SetMax0Right
	                            NEG  VelocityX
	                            ret
	SetMax0Right:                                               	;if so, overwrites it with max value allowed
	                            Mov  VelocityX, ax
	                            NEG  velocityX
	                            RET

	Neg45ReflectionRight:       
	                            inc  velocityX                  	;Increment VelocityX
	                            mov  ax, velocityX
	                            mov  velocityY, ax              	;Copy VelocityX into Y
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax              	;Check that the Velocity in X, Y does not exceed max
	                            JG   SetMaxNeg45Right
	                            Neg  velocityX
	                            RET
	SetMaxNeg45Right:           
	                            mov  velocityX, ax              	;Correct Velocities
	                            mov  velocityY, ax
	                            neg  velocityX
	                            RET

	Pos45ReflectionRight:                                       	;Increment VelocityX
	                            inc  VelocityX
	                            mov  ax, VelocityX
	                            mov  VelocityY, ax              	;Copy it into VelocityY
	                            mov  ax, MaxVelocity
	                            cmp  velocityX, ax              	;Check that it does not exceed max allowed
	                            JG   SetMaxPos45Right
	                            Neg  VelocityY                  	;Flip Directions
	                            Neg  velocityX
	                            RET
	SetMaxPos45Right:           
	                            Mov  VelocityX, ax
	                            neg  velocityX
	                            mov  VelocityY, ax
	                            neg  VelocityY                  	;Correct Values
	                            RET

	PerfectReflectionRight:     
	                            Neg  velocityX                  	;Keep the current angle but reflect it to the other paddle.
	                            RET

	Incidence30Right:           
	                            mov  ax, 0                      	;Remove Y component of Velocity
	                            mov  VelocityY, 0
	                            inc  velocityX                  	;Increment Velocity in X direction
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax
	                            JG   SetMax30Right
	                            Neg  velocityX
	                            RET
	SetMax30Right:              
	                            mov  velocityX, ax
	                            neg  velocityX
	                            RET

	IncidencePos45Right:        
	                            mov  ax, velocityX
	                            add  VelocityX, 2
	                            mov  VelocityY, AX
	                            inc  VelocityY
	                            mov  ax, MaxVelocity
	                            CMP  velocityX, ax
	                            JG   SetMaxInc45Pos
	                            Neg  velocityX
	                            RET
	SetMaxInc45Pos:             
	                            mov  VelocityX, ax
	                            mov  VelocityY, ax
	                            dec  VelocityY
	                            neg  velocityX
	                            RET

	IncidenceNegative45Right:   
	                            mov  ax, VelocityX
	                            add  VelocityX, 2
	                            mov  VelocityY, AX
	                            inc  VelocityY
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax
	                            JG   SetMaxInc45Neg
	                            Neg  velocityX
	                            Neg  VelocityY
	                            RET
	SetMaxInc45Neg:             
	                            Mov  VelocityX, ax
	                            mov  VelocityY, ax
	                            dec  velocityY
	                            neg  velocityX
	                            neg  VelocityY
	                            RET




	NoColRight:                 
	                            RET



ReflectionRight endp

	;instructions for left paddle's physics post collision
ReflectionLeft proc near
	                            Mov  RightCollisionFlag, 00     	;Zero the right paddle's collision flag
	                            inc  LeftCollisionFlag          	;Set its own collision flag to 1

	                            NEG  VelocityX                  	;Negate Velocity in X such that Right calculations are still valid

	                            CMP  VelocityY, 0               	;Checks that the angle of incidence is zero
	                            JE   IncidenceZeroLeft

	                            mov  ax, BallSize
	                            shr  ax, 1
	                            add  ax, BallY                  	;Calculates Ball Center in Y
	                            mov  bx, PaddleHeight
	                            shr  bx, 1
	                            add  bx, LeftPaddle_Y           	;Calculates Paddle Center in Y
	                            CMP  ax, bx
	                            JE   PerfectReflectionLeft      	;If the ball hits paddle center, mirror reflection

	                            mov  ax, velocityX
	                            sub  ax, VelocityY
	                            CMP  ax, 1
	                            JE   Incidence30Left
	                            CMP  ax, 0
	                            JE   IncidencePos45Left
	                            mov  ax, VelocityY
	                            CMP  ax, 0
	                            JL   NegativeYAngleLeft
	                            RET

	NegativeYAngleLeft:                                         	;Negates Y value such that previous calculations are still correct
	                            Neg  velocityY
	                            mov  ax, VelocityX
	                            sub  ax, VelocityY
	                            CMP  ax, 1
	                            JE   Incidence30Left
	                            CMP  ax, 0
	                            JE   IncidenceNegative45Left


	IncidenceZeroLeft:          
	                            mov  ax, BallSize
	                            shr  ax, 1
	                            add  ax, BallY                  	;Calculates Ball center in Y
	                            mov  bx, PaddleHeight
	                            shr  bx, 1
	                            add  bx, LeftPaddle_Y           	;Calculates Paddle Center in Y
	                            cmp  ax, bx
	                            JE   ZeroReflectionLeft         	;If they are both the same, then the ball hit the center and the collision has a reflection angle of zero
	                            CMP  ax, bx
	                            JL   Neg45ReflectionLeft        	;If it hits the lower part of the paddle, it reflects downwards
	                            CMP  ax, bx
	                            JG   Pos45ReflectionLeft        	;If it hits the upper part of the paddle, it reflects upwards.
	                            JMP  noColLeft

	ZeroReflectionLeft:         
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax              	;check that the ball velocity is not above max allowed for proper physics
	                            JG   SetMax0Left
	                            ret
	SetMax0Left:                                                	;if so, overwrites it with max value allowed
	                            Mov  VelocityX, ax
	                            RET

	Neg45ReflectionLeft:        
	                            inc  velocityX                  	;Increment VelocityX
	                            mov  ax, velocityX
	                            mov  velocityY, ax              	;Copy VelocityX into Y
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax              	;Check that the Velocity in X, Y does not exceed max
	                            JG   SetMaxNeg45Left
	                            RET
	SetMaxNeg45Left:            
	                            mov  velocityX, ax              	;Correct Velocities
	                            mov  velocityY, ax
	                            RET

	Pos45ReflectionLeft:                                        	;Increment VelocityX
	                            inc  VelocityX
	                            mov  ax, VelocityX
	                            mov  VelocityY, ax              	;Copy it into VelocityY
	                            mov  ax, MaxVelocity
	                            cmp  velocityX, ax              	;Check that it does not exceed max allowed
	                            JG   SetMaxPos45Left
	                            Neg  VelocityY                  	;Flip Directions
	                            RET
	SetMaxPos45Left:            
	                            Mov  VelocityX, ax
	                            mov  VelocityY, ax
	                            neg  VelocityY                  	;Correct Values
	                            RET

	PerfectReflectionLeft:      
	;Keep the current angle but reflect it to the other paddle.
	                            RET

	Incidence30Left:            
	                            mov  ax, 0                      	;Remove Y component of Velocity
	                            mov  VelocityY, 0
	                            inc  velocityX                  	;Increment Velocity in X direction
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax
	                            JG   SetMax30Left
	                            RET
	SetMax30Left:               
	                            mov  velocityX, ax
	                            RET

	IncidencePos45Left:         
	                            mov  ax, velocityX
	                            add  VelocityX, 2
	                            mov  VelocityY, AX
	                            inc  VelocityY
	                            mov  ax, MaxVelocity
	                            CMP  velocityX, ax
	                            JG   SetMaxInc45PosLeft
	                            RET
	SetMaxInc45PosLeft:         
	                            mov  VelocityX, ax
	                            mov  VelocityY, ax
	                            dec  VelocityY
	                            RET


	IncidenceNegative45Left:    
	                            mov  ax, VelocityX
	                            add  VelocityX, 2
	                            mov  VelocityY, AX
	                            inc  VelocityY
	                            mov  ax, MaxVelocity
	                            CMP  VelocityX, ax
	                            JG   SetMaxInc45NegLeft
	                            Neg  VelocityY
	                            RET
	SetMaxInc45NegLeft:         
	                            Mov  VelocityX, ax
	                            mov  VelocityY, ax
	                            dec  velocityY
	                            neg  VelocityY
	                            RET




	NoColLeft:                  
	                            RET

ReflectionLeft endp
	;draws ball from the updated ball position in move
DRAW_BALL proc near

	                            mov  cx, BallX                  	;initial X c
	                            mov  dx, BallY                  	;initial Y
	; initial (top left position of ball)

	BallPosition:               
	;set video config
	                            mov  ah, 0ch
	                            mov  al, BallColor
	                            mov  bh, 00h                    	;set page
	                            int  10h
        
	                            inc  cx
	                            mov  ax, cx
	                            sub  ax, BallX                  	;current pixel draw between initial and final
	                            CMP  ax, BallSize               	;check that the pixel is not drawn bigger than the size allocated then move to a new column
	                            JNG  BallPosition

	                            mov  cx, BallX                  	;move to start of X
	                            inc  dx                         	;increment Y to move to next pixel

	                            mov  ax, dx
	                            sub  ax, BallY                  	;ax now holds BallY - BallSize
	                            cmp  ax, BallSize               	;Check that the ball's Y dimension is correct
	                            JNG  BallPosition

	                            ret
DRAW_BALL endp

	;draw paddle's position from the position calculated by playermove
drawPaddle proc near
	                            mov  cx, LeftPaddle_X
	                            mov  dx, LeftPaddle_Y

	drawPaddleLeft:             
	                            mov  ah, 0ch
	                            mov  al, LeftPaddleColor
	                            mov  bh, 00h                    	;set page
	                            int  10h

	                            inc  cx
	                            mov  ax, cx
	                            sub  ax, LeftPaddle_X           	;current pixel draw between initial and final
	                            CMP  ax, Paddlewidth            	;check that the pixel is not drawn bigger than the size allocated then move to a new column
	                            JNG  drawPaddleLeft

	                            mov  cx, LeftPaddle_X           	;move to a new column (change y)
	                            inc  dx

	                            mov  ax, dx
	                            sub  ax, LeftPaddle_Y
	                            cmp  ax, PaddleHeight
	                            JNG  drawPaddleLeft

	                            mov  cx, RightPaddle_X
	                            mov  dx, RightPaddle_Y
	drawPaddleRight:            
	                            mov  ah, 0ch
	                            mov  al, RightPaddleColor
	                            mov  bh, 00h                    	;set page
	                            int  10h

	                            inc  cx
	                            mov  ax, cx
	                            sub  ax, RightPaddle_X          	;current pixel draw between initial and final
	                            CMP  ax, Paddlewidth            	;check that the pixel is not drawn bigger than the size allocated then move to a new column
	                            JNG  drawPaddleRight

	                            mov  cx, RightPaddle_X          	;move to a new column (change y)
	                            inc  dx

	                            mov  ax, dx
	                            sub  ax, RightPaddle_Y
	                            cmp  ax, PaddleHeight
	                            JNG  drawPaddleRight

	                            ret
drawPaddle endp

	;calculate paddle positions given user input
playermove proc near

	LeftPaddleMovement:         
	                            mov  ah, 01h
	                            int  16h
	                            jz   RightPaddleMovement
        

	press_left:                 
	                            mov  ah, 0
	                            int  16h
        
	                            CMP  al, 77h                    	;'w'
	                            JE   MoveLeftUp
	                            CMP  al, 57h                    	;'W'
	                            JE   MoveLeftUp

	                            CMP  AL, 73h                    	;'s'
	                            JE   MoveLeftDown
	                            CMP  al, 53h                    	;'S'
	                            JE   MoveLeftDown
            
	                            JMP  RightPaddleMovement

	MoveLeftUp:                 
	                            CMP  LeftPaddleColor, 0fh
	                            JNE  MoveLeftDownInvert
	MoveLeftUpInvert:           
	                            mov  ax, LeftPaddleMoveSpeed
	                            sub  LeftPaddle_Y, ax           	;update LeftPaddle position (LeftPaddle - Speed) = CurrentPos
	                            CMP  LeftPaddle_Y, 0            	;check that the LeftPaddle position is not at the upper border of the screen
	                            JL   LeftOutofBoundsUP
	                            JMP  RightPaddleMovement        	;movement checked, jump to check Player 2's movement

	LeftOutofBoundsUP:          
	                            mov  ax, 0                      	;reset upper pixel of left paddle to be at the upper border of the screen
	                            mov  leftPaddle_y, ax           	;set LeftPaddle_Y top pixel 0
	                            JMP  RightPaddleMovement        	;Check player 2 input
                    

	MoveLeftDown:               
	                            CMP  LeftPaddleColor, 0fh
	                            JNE  MoveLeftUpInvert
	MoveLeftDownInvert:         
	                            mov  ax, LeftPaddleMoveSpeed
	                            add  LeftPaddle_Y, ax           	;update LeftPaddle position (LeftPaddle + Speed) = CurrentPos
	                            mov  ax, heightScreen           	;ax holds heightscreen
	                            sub  ax, PaddleHeight           	;AX now holds heightScreen - PaddleHeight -->
	                            CMP  LeftPaddle_Y, ax           	;checks that the bottom pixel of the paddle is not at the bottom border
	                            JGE  LeftOutofBoundsDOWN
	                            JMP  RightPaddleMovement

	LeftOutofBoundsDOWN:        
	                            mov  leftPaddle_y, ax           	;set LeftPaddle_Y's bottom pixel to the bottom border (139h)
	                            JMP  RightPaddleMovement        	;Check player 2 input




	RightPaddleMovement:        
  
	                            CMP  al, 6Fh                    	;'o'
	                            JE   MoveRightUp
	                            CMP  al, 4Fh                    	;'O'
	                            JE   MoveRightUp

	                            CMP  al, 6ch                    	;'l'
	                            JE   MoveRightDown
	                            CMP  al, 4ch                    	;'L'
	                            JE   MoveRightDown
        
	                            JMP  noinput                    	;Player 2 is checked after 1, thus no input here means no input this frame

	MoveRightUp:                
	                            CMP  RightPaddleColor, 0fh
	                            JNE  MoveRightDownInvert
	MoveRightUpInvert:          
	                            mov  ax, RightPaddleMoveSpeed
	                            sub  RightPaddle_Y, ax
	                            CMP  RightPaddle_Y, 0           	;Check that the RightPaddle's top pixel is not at the upper border
	                            JL   RightOutofBoundsUP
	                            JMP  noinput

	RightOutofBoundsUP:         
	                            mov  ax, 0
	                            mov  RightPaddle_y, ax
	                            JMP  noinput


	MoveRightDown:              
	                            CMP  RightPaddleColor, 0Fh
	                            JNE  MoveRightUpInvert
	MoveRightDownInvert:        
	                            mov  ax, RightPaddleMoveSpeed
	                            add  RightPaddle_Y, ax
	                            mov  ax, heightScreen
	                            sub  ax, PaddleHeight
	                            CMP  RightPaddle_Y, ax          	;Check that the RightPaddle's bottom pixel is not at the lower border
	                            JGE  RightOutofBoundsDOWN
	                            JMP  noinput

	RightOutofBoundsDOWN:       
	                            mov  RightPaddle_y, ax
	                            JMP  noinput


        


    
    
    
	noinput:                    
	                            ret
playermove endp
	;centers ball when a point is scored (ball is at left/right screen border)
BallPosReset proc near
	                            mov  ax, CenterX
	                            mov  BallX, ax

	                            mov  ax, CenterY
	                            mov  BallY, ax

	                            mov  ActivePowerUpFlag, 0

	                            CMP  velocityX, 0
	                            JG   Player1Scored
	                            CMP  VelocityX, 0
	                            JL   Player2Scored
	                            ret
	Player1Scored:              
	                            inc  Player1Score
	                            mov  ax, 1
	                            mov  ResetFlag, ax
	                            mov  DirectionFlag, ax
	                            ret
	Player2Scored:              
	                            inc  Player2Score
	                            mov  ax, 1
	                            mov  ResetFlag, ax
	                            mov  ax, 2
	                            mov  DirectionFlag, ax

	                            mov  al, 0Fh
	                            mov  BallColor, al
	                            RET
BallPosReset endp
	;Pauses the ball until the 'J' key is pressed at which point play resumes
GoalScored proc near
	                            CMP  ResetFlag, 0
	                            JE   WaitForGoal
	                            CMP  Player1Score, 3Ah
	                            JGE  WaitForGoal
	                            CMP  Player2Score, 3Ah
	                            JGE  WaitForGoal
	                            Mov  BallColor, 0Fh
	                            mov  RandomNumber, 00h
	                            mov  ah, 0ch
	                            mov  al, 0
	                            int  21h                        	;int 21h/0ch with al 0 flushes the keyboard stdin buffer:
	;fixes a bug where holding down a key when a goal is scored does not pause game physiics
	                            Call BallAngle
	                            mov  ResetFlag, 0
	                            xor  al, al
	check:                      
	                            mov  ah, 01h
	                            int  16h
	                            jz   checkbutton
	                            JMP  WaitForGoal
	checkbutton:                
	                            mov  ah, 0
	                            int  16h
	                            cmp  al, 4Ah
	                            JE   cont
	                            CMP  al, 6Ah
	                            JE   cont
	                            JMP  checkbutton
	cont:                       
	                            mov  ax, PaddleDefaultY
	                            mov  LeftPaddle_Y, ax
	                            mov  RightPaddle_Y, ax
	                            mov  ax, DefaultPaddleMoveSpeed
	                            mov  LeftPaddleMoveSpeed, ax
	                            mov  RightPaddleMoveSpeed, ax
	                            mov  al, 0fh
	                            mov  RightPaddleColor, al
	                            mov  LeftPaddleColor, al

	                            RET
	WaitForGoal:                
	                            RET
GoalScored endp
	;Check that a PowerUp should be Spawned
CheckForPowerups proc near
	                            mov  al, RandomNumber
	                            CMP  AL, 1
	                            JE   PowerUpMaxSpeed
	                            CMP  AL, 3
	                            JE   PowerUpPaddleSpeed
	                            CMP  AL, 5
	                            JE   PowerUpMirrorBall
	                            CMP  AL, 7
	                            JE   PowerUpInvertControl
	                            RET

	PowerUpMaxSpeed:            
	                            mov  al, 04H
	                            mov  PowerUpColor, al
	                            Call DrawPowerUp
	                            RET

	PowerUpPaddleSpeed:         
	                            mov  al, 05h
	                            mov  PowerUpColor, al
	                            Call DrawPowerUp
	                            RET

	PowerUpMirrorBall:          
	                            mov  al, 03h
	                            Mov  PowerUpColor, al
	                            Call DrawPowerUp
	                            RET

	PowerUpInvertControl:       
	                            mov  al, 0eh
	                            Mov  PowerUpColor, al
	                            Call DrawPowerUp
	                            RET
    

	                            RET
CheckForPowerups endp
	;Draws the PowerUp, calls the function for the specific powerup, and sets the collision for it.
DrawPowerUp proc near

	                            Mov  ActivePowerUpFlag,1
	                            mov  cx, DrawPowerUpX
	                            mov  dx, DrawPowerUpY
	                            CMP  RandomNumber, 1
	                            JE   DrawMaxSpeed
	                            CMP  RandomNumber, 3
	                            JE   DrawMaxSpeed
	                            CMP  RandomNumber, 5
	                            JE   DrawMaxSpeed
	                            CMP  RandomNumber, 7
	                            JE   DrawMaxSpeed
    
	                            JMP  NoPowerUp

	DrawMaxSpeed:               
        
    
	                            mov  ah, 0ch
	                            mov  al, PowerUpColor
	                            mov  bh, 00h
	                            int  10h

	                            inc  cx
	                            mov  ax, cx
	                            sub  ax, DrawPowerUpX
	                            CMP  ax, PowerUpSizeX
	                            JNG  DrawMaxSpeed

	                            mov  cx, DrawPowerUpX
	                            inc  dx

	                            mov  ax, dx
	                            sub  ax, DrawPowerUpY
	                            cmp  ax, PowerUpSizeY
	                            JNG  DrawMaxSpeed
	                            JMP  CheckCollision



	CheckCollision:             
	                            mov  ax, BallX
	                            add  ax, BallSize
	                            CMP  ax, DrawPowerUpX
	                            JNG  NoPowerUp

	                            mov  ax, DrawPowerUpX
	                            add  ax, PowerUpSizeX
	                            cmp  BallX, ax
	                            JNL  NoPowerUp

	                            mov  ax, BallY
	                            add  ax, BallSize
	                            CMP  ax, DrawPowerUpY
	                            JNG  NoPowerUp

	                            mov  ax, DrawPowerUpY
	                            add  ax, PowerUpSizeY
	                            cmp  BallY, ax
	                            JNL  NoPowerUp
    
	                            JMP  ProcPowerUp

	                            RET
	ProcPowerUp:                
	                            mov  al, RandomNumber
	                            CMP  al, 1
	                            JE   ProcMaxSpeed
	                            mov  al, RandomNumber
	                            CMP  al, 3
	                            JE   ProcPaddleSpeed
	                            mov  al, RandomNumber
	                            CMP  al, 5
	                            JE   ProcMirrorBall
	                            mov  al, RandomNumber
	                            CMP  al, 7
	                            JE   ProcInvertControls
	                            RET

	ProcMaxSpeed:               
	                            mov  al, 04H
	                            mov  BallColor, al
	                            mov  al, 1
	                            mov  ActivePowerUpFlag, al
	                            Call MaxSpeedPowerUp
	                            mov  RandomNumber, 0
	                            RET

	ProcPaddleSpeed:            
	                            mov  al, 1
	                            mov  ActivePowerUpFlag, al
	                            Call PaddleSpeedPowerUp
	                            mov  RandomNumber, 0
	                            RET

	ProcMirrorBall:             
	                            mov  al, 1
	                            mov  ActivePowerUpFlag, al
	                            Call MirrorBallPowerUp
	                            mov  RandomNumber, 0
	                            RET

	ProcInvertControls:         
	                            Mov  al, 1
	                            mov  ActivePowerUpFlag, al
	                            call InvertControlPowerUp
	                            mov  RandomNumber, 0
	                            RET

	NoPowerUp:                  
	                            RET
DrawPowerUp endp

	;Code for the first PowerUp that sets Ball Speed to Max Speed
MaxSpeedPowerUp proc near

	                            Mov  al, 4h
	                            mov  BallColor, al
                
	                            mov  ax, velocityX              	;AX = VelocityX
	                            sub  ax, VelocityY              	;AX = VelocityX - VelocityY
	                            CMP  ax, 0                      	; if Vx = Vy, the angle is 45
	                            JE   CheckFortyFiveDirection    	; jump to check if (Vx,Vy) or (-Vx,-Vy)
	                            CMP  ax, 1                      	;If X - Y = 1, angle is +30
	                            JE   MaxSpeedThirty
	                            CMP  ax, velocityX              	; If Ax = VelocityX, Angle is zero
	                            JE   MaxSpeedZero               	; Check direction of Vx
	                            CMP  ax, -1
	                            JE   MaxNegativeThirtyXY        	;If X - Y = -1, the angle is -30

	                            xor  ah, ah
	                            mov  cl, 2
	                            div  cl                         	;divide the velocity by 2 to check its angle
	                            CMP  al, 0
	                            JG   PosXNegY
	                            JMP  PosYNegX


	PosXNegY:                   
	                            CMP  ah, 0
	                            JE   PosXNegYFortyFive
	                            CMP  ah, 0
	                            JNE  PosXNegYThirty

	PosYNegX:                   
	                            CMP  ah, 0
	                            JE   PosYNegXFortyFive
	                            cmp  ah, 0
	                            JNE  PosYNegXThirty
	                            RET
    


	CheckFortyFiveDirection:    
	                            CMP  VelocityX, 0
	                            JG   MaxSpeedFortyFive
	                            JMP  NEGATIVEMaxSpeedFortyFiveXY

	MaxSpeedFortyFive:          
	                            mov  ax, MaxVelocity
	                            mov  VelocityY, ax
	                            mov  VelocityY, ax
	                            RET

	MaxSpeedThirty:             
	                            mov  ax, MaxVelocity
	                            mov  velocityX, ax
	                            mov  VelocityY, ax
	                            dec  VelocityY
	                            RET

	MaxNegativeThirtyXY:        
	                            mov  ax, MaxVelocity
	                            mov  VelocityX, AX
	                            Neg  VelocityX
	                            mov  VelocityY, AX
	                            dec  VelocityY
	                            NEG  VelocityY
	                            RET

	NEGATIVEMaxSpeedFortyFiveXY:
	                            mov  ax, MaxVelocity
	                            mov  velocityX, ax
	                            mov  velocityY, ax
	                            NEG  VelocityX
	                            NEG  VelocityY
	                            RET

	MaxSpeedZero:               
	                            CMP  VelocityX, 0
	                            JG   PositiveMaxZero
	                            JMP  NegativeMaxZero
	PositiveMaxZero:            
	                            mov  ax, MaxVelocity
	                            mov  velocityX, ax
	                            RET
	NegativeMaxZero:            
	                            mov  ax, MaxVelocity
	                            mov  VelocityX, ax
	                            neg  VelocityX
	                            RET

	PosXNegYThirty:             
	                            Mov  ax, MaxVelocity
	                            mov  VelocityX, ax
	                            mov  velocityY, AX
	                            dec  VelocityY
	                            NEG  VelocityY
	                            RET

	PosYNegXThirty:             
	                            mov  ax, MaxVelocity
	                            mov  velocityX, ax
	                            mov  VelocityY, ax
	                            dec  VelocityY
	                            neg  VelocityX
	                            RET

	PosXNegYFortyFive:          
	                            mov  ax, MaxVelocity
	                            mov  VelocityX, AX
	                            mov  VelocityY, ax
	                            NEG  VelocityY
	                            RET

	PosYNegXFortyFive:          
	                            mov  ax, MaxVelocity
	                            mov  VelocityX, ax
	                            mov  velocityY, ax
	                            NEG  VelocityX

	                            RET


MaxSpeedPowerUp endp

PaddleSpeedPowerUp proc near
	                            CMP  VelocityX, 0
	                            JG   LeftPaddleIncreaseSpeed
	                            CMP  VelocityX, 0
	                            JL   RightPaddleIncreaseSpeed

	LeftPaddleIncreaseSpeed:    
	                            mov  ax, LeftPaddleMoveSpeed
	                            add  ax, 4
	                            mov  LeftPaddleMoveSpeed, ax
	                            RET
	RightPaddleIncreaseSpeed:   
	                            mov  ax, RightPaddleMoveSpeed
	                            add  ax, 4
	                            mov  RightPaddleMoveSpeed, ax
	                            RET

PaddleSpeedPowerUp endp

InvertControlPowerUp proc near
	                            mov  ax, VelocityX
	                            CMP  ax, 0
	                            JG   InvertRight
	                            CMP  ax, 0
	                            JL   Invertleft

	InvertRight:                
	                            mov  al, 0eh
	                            mov  RightPaddleColor, al
	                            RET

	InvertLeft:                 
	                            mov  al, 0eh
	                            mov  LeftPaddleColor, al
	                            RET
InvertControlPowerUp endp


MirrorBallPowerUp proc near
	                            NEG  velocityY
	                            RET
MirrorBallPowerUp endp

	;The Main Pong Game
main proc near
	                            mov  dx, @data
	                            mov  ds, dx



	                            call StartMenu

	GameStart:                  
	                            Call BallAngle

	                            call clearscreen


	Time:                       

	                            mov  ah, 2Ch                    	;system time to draw frame
	                            int  21h

	                            cmp  dl, CurrentTime            	;check if time has passed
	                            JE   Time
    
	                            mov  CurrentTime, dl            	;re-set time with current system time
	                            call clearscreen

	                            call UpdatePlayerScores
	                            call MidScreenDivider

	                            call move                       	;calculate ball position
	                            call DRAW_BALL                  	;draw ball position

	                            call playermove                 	;calculate paddle position
	                            call drawPaddle                 	;draw paddle position

	                            Call CheckForPowerups
    
	                            Call GoalScored

	                            Call EndMenu

	                            CMP  NewGame, 0
	                            JNE  StartNewGame
	                            JMP  Time                       	;calculate next frame

     
	StartNewGame:               
	                            mov  ax, 0
	                            mov  NewGame, ax
	                            mov  ax, 30h
	                            mov  Player1Score, ax
	                            mov  Player2Score, ax
	                            JMP  GameStart







	                            HLT

	EscapePressed:              
	                            call clearscreen

	                            MOV  AH,4CH
	                            INT  21H

main endp



end main

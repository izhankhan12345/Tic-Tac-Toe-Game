INCLUDE Irvine32.inc

.data
; The nine cells contain their position until a player claims them.
board           BYTE '1','2','3','4','5','6','7','8','9'
currentPlayer   BYTE 'X'
menuChoice      BYTE ?
replayChoice    BYTE ?
moveIndex       DWORD ?
player1Score    DWORD 0
player2Score    DWORD 0

titleText       BYTE "TIC-TAC-TOE",0
menuText        BYTE "1. Play Game",13,10,
                     "2. Instructions",13,10,
                     "3. Exit",13,10,0
menuPrompt      BYTE "Choose an option (1-3): ",0
menuError       BYTE "Invalid choice. Please select 1, 2, or 3.",0
instructionsText BYTE "Two players take turns placing X and O on the board.",13,10,
                      "Enter a position from 1 through 9 to claim that cell.",13,10,
                      "The first player with three marks in a row wins.",13,10,
                      "Rows, columns, and both diagonals count.",13,10,
                      "If all nine cells are used with no winner, the game is a draw.",13,10,13,10,
                      "Press any key to return to the main menu.",0

rowOneText      BYTE "  1 | 2 | 3",0
rowTwoText      BYTE "  4 | 5 | 6",0
rowThreeText    BYTE "  7 | 8 | 9",0
dividerText     BYTE " ---+---+---",0
turnText        BYTE "Current player: ",0

player1Prompt   BYTE "Player 1 (X), enter your position: ",0
player2Prompt   BYTE "Player 2 (O), enter your position: ",0
numberError     BYTE "Invalid number or integer overflow. Try again.",0
rangeError      BYTE "Invalid position. Enter a number from 1 to 9.",0
occupiedError   BYTE "That position is already occupied. Try again.",0

player1WinsText BYTE "Player 1 (X) wins!",0
player2WinsText BYTE "Player 2 (O) wins!",0
drawText        BYTE "The round is a draw.",0
scoresTitle     BYTE "Scores",0
player1ScoreText BYTE "Player 1 (X): ",0
player2ScoreText BYTE "Player 2 (O): ",0
replayPrompt    BYTE "Play Again? (Y/N): ",0
replayError     BYTE "Please enter Y or N.",0
goodbyeText     BYTE "Thanks for playing!",0

.code
main PROC
    ; Scores are initialized once and survive every replay.
    mov player1Score, 0
    mov player2Score, 0

mainMenu:
    call DisplayMenu
    call ReadChar
    mov menuChoice, al
    call Crlf

    cmp menuChoice, '1'
    je startGame
    cmp menuChoice, '2'
    je showInstructions
    cmp menuChoice, '3'
    je exitGame

    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET menuError
    call WriteString
    call SetDefaultColor
    call Crlf
    call WaitMsg
    jmp mainMenu

showInstructions:
    call DisplayInstructions
    jmp mainMenu

startGame:
    call InitializeBoard
    mov currentPlayer, 'X'
    call DisplayBoard

gameLoop:
    call GetPlayerMove
    ; Save the index before loading the mark into DL.
    mov moveIndex, eax
    mov dl, currentPlayer
    mov eax, moveIndex
    mov board[eax], dl
    call DisplayBoard

    call CheckWinner
    cmp eax, 1
    je roundWon

    call CheckDraw
    cmp eax, 1
    je roundDrawn

    ; Switch only after a valid move with no winner or draw.
    cmp currentPlayer, 'X'
    jne switchToPlayer1
    mov currentPlayer, 'O'
    jmp showNextTurn

switchToPlayer1:
    mov currentPlayer, 'X'

showNextTurn:
    call DisplayBoard
    jmp gameLoop

roundWon:
    call UpdateScore
    cmp currentPlayer, 'X'
    jne player2Won
    mov eax, green
    call SetTextColor
    mov edx, OFFSET player1WinsText
    call WriteString
    call SetDefaultColor
    call Crlf
    jmp showRoundScores

player2Won:
    mov eax, green
    call SetTextColor
    mov edx, OFFSET player2WinsText
    call WriteString
    call SetDefaultColor
    call Crlf

showRoundScores:
    call DisplayScores
    jmp roundComplete

roundDrawn:
    mov eax, lightMagenta
    call SetTextColor
    mov edx, OFFSET drawText
    call WriteString
    call SetDefaultColor
    call Crlf
    call DisplayScores

roundComplete:
    call AskReplay
    cmp eax, 1
    je startGame

exitGame:
    mov edx, OFFSET goodbyeText
    call WriteString
    call Crlf
    exit
main ENDP

; Prints the three menu options. Input is handled by main with ReadChar.
DisplayMenu PROC
    call Clrscr
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET titleText
    call WriteString
    call SetDefaultColor
    call Crlf
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET menuText
    call WriteString
    call SetDefaultColor
    mov edx, OFFSET menuPrompt
    call WriteString
    ret
DisplayMenu ENDP

; Shows the rules and waits for a key before returning to the menu.
DisplayInstructions PROC
    call Clrscr
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET titleText
    call WriteString
    call SetDefaultColor
    call Crlf
    call Crlf
    mov edx, OFFSET instructionsText
    call WriteString
    call ReadChar
    call Crlf
    ret
DisplayInstructions ENDP

; Restores the position labels for a new round without touching scores.
InitializeBoard PROC
    mov ecx, 0
    mov al, '1'
initializeLoop:
    mov board[ecx], al
    inc al
    inc ecx
    cmp ecx, 9
    jb initializeLoop
    ret
InitializeBoard ENDP

; Draws the grid with Gotoxy's documented DH=row, DL=column convention.
DisplayBoard PROC
    call Clrscr
    mov dh, 0
    mov dl, 0
    call Gotoxy
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET titleText
    call WriteString
    call SetDefaultColor

    mov dh, 2
    mov dl, 0
    call Gotoxy
    mov eax, white
    call SetTextColor
    mov edx, OFFSET rowOneText
    call WriteString
    call SetDefaultColor

    mov dh, 3
    mov dl, 0
    call Gotoxy
    mov eax, white
    call SetTextColor
    mov edx, OFFSET dividerText
    call WriteString
    call SetDefaultColor

    mov dh, 4
    mov dl, 0
    call Gotoxy
    mov eax, white
    call SetTextColor
    mov edx, OFFSET rowTwoText
    call WriteString
    call SetDefaultColor

    mov dh, 5
    mov dl, 0
    call Gotoxy
    mov eax, white
    call SetTextColor
    mov edx, OFFSET dividerText
    call WriteString
    call SetDefaultColor

    mov dh, 6
    mov dl, 0
    call Gotoxy
    mov eax, white
    call SetTextColor
    mov edx, OFFSET rowThreeText
    call WriteString
    call SetDefaultColor

    ; Replace each printed position label with its current board value.
    mov dh, 2
    mov dl, 2
    call Gotoxy
    mov al, board[0]
    call WriteBoardCell
    mov dh, 2
    mov dl, 6
    call Gotoxy
    mov al, board[1]
    call WriteBoardCell
    mov dh, 2
    mov dl, 10
    call Gotoxy
    mov al, board[2]
    call WriteBoardCell

    mov dh, 4
    mov dl, 2
    call Gotoxy
    mov al, board[3]
    call WriteBoardCell
    mov dh, 4
    mov dl, 6
    call Gotoxy
    mov al, board[4]
    call WriteBoardCell
    mov dh, 4
    mov dl, 10
    call Gotoxy
    mov al, board[5]
    call WriteBoardCell

    mov dh, 6
    mov dl, 2
    call Gotoxy
    mov al, board[6]
    call WriteBoardCell
    mov dh, 6
    mov dl, 6
    call Gotoxy
    mov al, board[7]
    call WriteBoardCell
    mov dh, 6
    mov dl, 10
    call Gotoxy
    mov al, board[8]
    call WriteBoardCell

    mov dh, 8
    mov dl, 0
    call Gotoxy
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET turnText
    call WriteString
    call SetDefaultColor
    mov al, currentPlayer
    call WriteBoardCell
    call Crlf
    ret
DisplayBoard ENDP

; Reads and validates one move, then returns a zero-based board index in EAX.
GetPlayerMove PROC
movePrompt:
    cmp currentPlayer, 'X'
    jne promptPlayer2
    mov eax, green
    mov edx, OFFSET player1Prompt
    jmp printMovePrompt
promptPlayer2:
    mov eax, lightCyan
    mov edx, OFFSET player2Prompt
printMovePrompt:
    call SetTextColor
    call WriteString
    call SetDefaultColor
    call ReadInt
    jo invalidNumber          ; Check ReadInt's overflow flag immediately.

    cmp eax, 1
    jl invalidRange
    cmp eax, 9
    jg invalidRange
    dec eax                   ; Convert positions 1-9 to indexes 0-8.

    cmp board[eax], 'X'
    je invalidOccupied
    cmp board[eax], 'O'
    je invalidOccupied
    ret

invalidNumber:
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET numberError
    call WriteString
    call SetDefaultColor
    call Crlf
    jmp movePrompt
invalidRange:
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET rangeError
    call WriteString
    call SetDefaultColor
    call Crlf
    jmp movePrompt
invalidOccupied:
    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET occupiedError
    call WriteString
    call SetDefaultColor
    call Crlf
    jmp movePrompt
GetPlayerMove ENDP

; CheckLine arguments are pushed as third, second, first index.
; [EBP+8] is the first index; [EBP+12] and [EBP+16] follow.
; Returns EAX=1 for three equal non-empty marks, otherwise EAX=0.
CheckLine PROC
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov dl, board[eax]
    cmp dl, 'X'
    je checkRemainingCells
    cmp dl, 'O'
    jne lineNotWon

checkRemainingCells:
    mov ecx, [ebp+12]
    cmp dl, board[ecx]
    jne lineNotWon
    mov eax, [ebp+16]
    cmp dl, board[eax]
    jne lineNotWon
    mov eax, 1
    jmp lineFinished

lineNotWon:
    xor eax, eax
lineFinished:
    pop ebp
    ret 12
CheckLine ENDP

; Checks all eight rows, columns, and diagonals through stack-based CheckLine.
CheckWinner PROC
    push 2
    push 1
    push 0
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 5
    push 4
    push 3
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 8
    push 7
    push 6
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 6
    push 3
    push 0
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 7
    push 4
    push 1
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 8
    push 5
    push 2
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 8
    push 4
    push 0
    call CheckLine
    cmp eax, 1
    je winnerFound

    push 6
    push 4
    push 2
    call CheckLine
    cmp eax, 1
    je winnerFound

    xor eax, eax
    ret
winnerFound:
    mov eax, 1
    ret
CheckWinner ENDP

; Returns EAX=1 only when every cell contains X or O.
CheckDraw PROC
    mov ecx, 0
drawScan:
    cmp ecx, 9
    jae boardIsFull
    cmp board[ecx], 'X'
    je nextDrawCell
    cmp board[ecx], 'O'
    je nextDrawCell
    xor eax, eax
    ret
nextDrawCell:
    inc ecx
    jmp drawScan
boardIsFull:
    mov eax, 1
    ret
CheckDraw ENDP

; Adds one point to the winner; this is called once per completed winning round.
UpdateScore PROC
    cmp currentPlayer, 'X'
    jne addPlayer2Point
    inc player1Score
    ret
addPlayer2Point:
    inc player2Score
    ret
UpdateScore ENDP

; Prints both cumulative scores using Irvine32 decimal output.
DisplayScores PROC
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET scoresTitle
    call WriteString
    call Crlf

    mov edx, OFFSET player1ScoreText
    call WriteString
    mov eax, player1Score
    call WriteDec
    call Crlf

    mov edx, OFFSET player2ScoreText
    call WriteString
    mov eax, player2Score
    call WriteDec
    call Crlf
    call SetDefaultColor
    ret
DisplayScores ENDP

; Returns EAX=1 for Y, EAX=0 for N; other keys repeat the prompt.
AskReplay PROC
replayPromptAgain:
    mov edx, OFFSET replayPrompt
    call WriteString
    call ReadChar
    mov replayChoice, al
    call Crlf

    cmp replayChoice, 'Y'
    je replayYes
    cmp replayChoice, 'y'
    je replayYes
    cmp replayChoice, 'N'
    je replayNo
    cmp replayChoice, 'n'
    je replayNo

    mov eax, lightRed
    call SetTextColor
    mov edx, OFFSET replayError
    call WriteString
    call SetDefaultColor
    call Crlf
    jmp replayPromptAgain
replayYes:
    mov eax, 1
    ret
replayNo:
    xor eax, eax
    ret
AskReplay ENDP

; Writes a board mark in the player's color and restores the normal color.
; Input: AL is the board character to display.
WriteBoardCell PROC
    push eax
    cmp al, 'X'
    je boardCellX
    cmp al, 'O'
    je boardCellO
    mov eax, lightGray
    jmp setBoardCellColor
boardCellX:
    mov eax, green
    jmp setBoardCellColor
boardCellO:
    mov eax, lightCyan
setBoardCellColor:
    call SetTextColor
    pop eax
    call WriteChar
    call SetDefaultColor
    ret
WriteBoardCell ENDP

; Irvine32's standard default foreground is lightGray on a black background.
SetDefaultColor PROC
    mov eax, lightGray
    call SetTextColor
    ret
SetDefaultColor ENDP

END main

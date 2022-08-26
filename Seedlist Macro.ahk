#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetKeyDelay, 50

global SavesDirectory := "C:\Users\PodX1\Downloads\MultiMC\instances\Multi1\.minecraft\saves\"
global titleScreenDelay := 0
global delay := 45

global UsedSeedsPath := "seeds-used.txt"
global UsedSeedFile := ""
FileRead, UsedSeedFile, % UsedSeedsPath
global UsedSeedList := StrSplit(UsedSeedFile, "`n")

global SeedsFilePath := "seeds.txt"
global SeedFile := ""
FileRead, SeedFile, % SeedsFilePath
global SeedList := StrSplit(SeedFile, "`n")

global currentSeedIndex := 1

HasGameSaved() {
    rawLogFile := StrReplace(SavesDirectory, "saves", "logs\latest.log")
    StringTrimRight, logFile, rawLogFile, 1
    numLines := 0
    Loop, Read, %logFile%
    {
        numLines += 1
    }
    saved := False
    maxCounter := 50
    counter := 0
    while (!saved && counter < maxCounter)
    {
        Loop, Read, %logFile%
        {
            if ((numLines - A_Index) < 2)
            {
                if (InStr(A_LoopReadLine, "Stopping worker threads")) {
                    saved := True
                    break
                }
            }
        }
        counter++
        Sleep, 50
    }
    return saved
}

GoNext(){
    WinGetActiveTitle, Title
    IfNotInString Title, -
        CreateWorld()
    else {
        ExitWorld()
        HasGameSaved()
        Sleep, %titleScreenDelay%
        CreateWorld()
    }
}

GetNextSeed(idx){
    currentSeed := SeedList[idx]

    hasUsedSeed := HasUsedSeed(currentSeed)

    if(hasUsedSeed){
        return ""
    }

    FileAppend, %currentSeed%`n, %UsedSeedsPath%
    UsedSeedList.Push(currentSeed)
    return currentSeed
}

HasUsedSeed(currentSeed){
    for i, usedSeed in UsedSeedList
    {
        if(StrLen(usedSeed) > 0){
            if(usedSeed == currentSeed)
                return true
        }
    }
    return false
}

CreateWorld(){
    nextSeed := ""

    loopIndex := currentSeedIndex
    while(loopIndex <= SeedList.MaxIndex()){
        nextSeed := GetNextSeed(loopIndex++)

        if(nextSeed != "")
            break
    }
    currentSeedIndex := loopIndex

    if(nextSeed == "")
    {
        MsgBox % "No unused seeds left"
        return
    }

    SetKeyDelay, 0
    Send {Esc 3}
    Send {Shift Down}{Tab}{Enter}{Shift Up}
    Send ^a
    Send % nextSeed
    Send {Tab 5}
    Send {Enter}
    SetKeyDelay, delay
    Send {Shift Down}{Tab}{Shift Up}{Enter}
}

ExitWorld()
{
    SetKeyDelay, 0
    Send {Esc}{Tab 6}{Enter}+{Tab 3}{Enter}
}

^p:: CreateWorld()

return

#IfWinActive, Minecraft
    {
        RAlt::
            GoNext()
        return
    }
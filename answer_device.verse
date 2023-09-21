
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
answer_device := class(creative_device):

    @editable Trigger1:trigger_device = trigger_device{}
    @editable Trigger2:trigger_device = trigger_device{}
    @editable Trigger3:trigger_device = trigger_device{}
    @editable Trigger4:trigger_device = trigger_device{}
    @editable QuestionBoard : billboard_device = billboard_device{}
    @editable Candidate1 : billboard_device = billboard_device{}
    @editable Candidate2 : billboard_device = billboard_device{}
    @editable Candidate3 : billboard_device = billboard_device{}
    @editable Candidate4 : billboard_device = billboard_device{}
    @editable GroundBarrier : barrier_device = barrier_device{}
    @editable WallBarrier : barrier_device = barrier_device{}
    @editable MutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable MaxValue: int = 9

    var Question: question = question{Num1 := 1, Num2:= 1, Option1:= 1, Option2:= 2, Option3:= 3, Option4:= 4}


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Setup()
        MutatorZone.AgentEntersEvent.Subscribe(OnAgentEnter)
        Trigger1.TriggeredEvent.Subscribe(OnTriggerd1)
        Trigger2.TriggeredEvent.Subscribe(OnTriggerd2)
        Trigger3.TriggeredEvent.Subscribe(OnTriggerd3)
        Trigger4.TriggeredEvent.Subscribe(OnTriggerd4)

    Setup():void =
        QuestionBoard.SetShowBorder(false)
        Trigger1.Disable()
        Trigger2.Disable()
        Trigger3.Disable()
        Trigger4.Disable()

    OnAgentEnter(Agent: agent) : void =
        set Question = GenerateQuestion()
        QuestionBoard.SetShowBorder(false)
        QuestionBoard.SetText(StringToMessage("{Question.Num1} × {Question.Num2}"))
        QuestionBoard.ShowText()
        Candidate1.SetText(StringToMessage("{Question.Option1}"))
        Candidate1.ShowText()
        Candidate2.SetText(StringToMessage("{Question.Option2}"))
        Candidate2.ShowText()
        Candidate3.SetText(StringToMessage("{Question.Option3}"))
        Candidate3.ShowText()
        Candidate4.SetText(StringToMessage("{Question.Option4}"))
        Candidate4.ShowText()
        Trigger1.Enable()
        Trigger2.Enable()
        Trigger3.Enable()
        Trigger4.Enable()

    StringToMessage<localizes>(value:string) : message = "{value}"


    OnTriggerd1(MaybeAgent: ?agent) : void =
        Print("OnTriggerd1")
        Validate(Question.Option1, MaybeAgent)

    OnTriggerd2(MaybeAgent: ?agent) : void =
        Validate(Question.Option2, MaybeAgent)

    OnTriggerd3(MaybeAgent: ?agent) : void =
        Validate(Question.Option3, MaybeAgent)

    OnTriggerd4(MaybeAgent: ?agent) : void =
        Validate(Question.Option4, MaybeAgent)
        
    Validate(UserAnswer: int, MaybeAgent: ?agent): void =
        Result:=Question.Validate(UserAnswer)
        if (Result?):
            OnCorrect(MaybeAgent)
        else:
            OnWrong(MaybeAgent)

    OnWrong(MaybeAgent: ?agent): void =
        Print("Wrong")
        GroundBarrier.Disable()
        spawn{Reset()}

    OnCorrect(MaybeAgent: ?agent): void =
        Print("Correct")
        QuestionBoard.SetShowBorder(false)
        QuestionBoard.HideText()
        Candidate1.HideText()
        Candidate2.HideText()
        Candidate3.HideText()
        Candidate4.HideText()
        WallBarrier.Disable()
        spawn{Reset()}

    Reset()<suspends>: void =
        Sleep(3.0)
        WallBarrier.Enable()
        GroundBarrier.Enable()
        Trigger1.Disable()
        Trigger2.Disable()
        Trigger3.Disable()
        Trigger4.Disable()

    GenerateQuestion<private>(): question =
        LeftVal: int = GetRandomInt(2, MaxValue)
        RightVal: int = GetRandomInt(2, MaxValue)
        Correct: int = LeftVal * RightVal
        var Wrong1: int = -1
        loop:
            set Wrong1 = Correct + GetRandomInt(-10, 10)
            if (not Wrong1 = Correct and Wrong1 > 0):
                break
        var Wrong2: int = -1
        loop:
            set Wrong2 = Correct + GetRandomInt(-10, 10)
            if (not Wrong2 = Correct and not Wrong2 = Wrong1 and Wrong2 > 0):
                break
        var Wrong3: int = -1
        loop:
            set Wrong3 = Correct + GetRandomInt(-10, 10)
            if (not Wrong3 = Correct and not Wrong3 = Wrong1 and not Wrong3 = Wrong2 and Wrong3 > 0):
                break
        Options: []int = Shuffle(array {Correct, Wrong1, Wrong2, Wrong3})
        var NewQ: question = question{Num1 := 1, Num2:= 1, Option1:= 1, Option2:= 2, Option3:= 3, Option4:= 4}
        if (Op1:int = Options[0]):
            if(Op2:int = Options[1]):
                if (Op3:int = Options[2]):
                    if(Op4:int = Options[3]):
                        set NewQ = question{Num1 := LeftVal, Num2:= RightVal, Option1:= Op1, Option2:= Op2, Option3:= Op3, Option4:= Op4 }
        return NewQ


question := class:
    Num1 : int
    Num2 : int
    Option1 : int
    Option2 : int
    Option3 : int
    Option4 : int
        
    Validate(Selected: int) : logic = 
        if(Num1 * Num2 = Selected):
            true
        else:
            false
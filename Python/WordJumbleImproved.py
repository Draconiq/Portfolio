import random
Words = {
        "Hello" :"What you say when you see someone",
        "Bye": "What you say when your leaving",
        "Jump": "Opposite of Sit",
        "Sad": "If your not happy your are...",
        "Buy" : "Opposite of sell",
    }




def SanityCheck(Input,Word):
    if Input == Word:
        return 1
    elif Input.upper() == "HELP":
        return 2
    else:
        return 3
        
def WordJumble():
    Score = 100
    GuessWord = random.choice(list(Words))
    ShuffleWord = ''.join(random.sample(GuessWord,len(GuessWord)))
    print("The word you need to unjumble is ",ShuffleWord)
    print("If you are ever stuck then you can just say 'Help'")
    while True:
        Intro = input()
        Sanity = SanityCheck(Intro,GuessWord)
        if Sanity == 1:
            print("Congratlations you got the word your total score is", Score)
            break
        elif Sanity == 2:
            print(Words[GuessWord])
            if Score > 20:
                Score -= 20
        elif Sanity == 3:
            print("You got it wrong, try again")
            
            
WordJumble()

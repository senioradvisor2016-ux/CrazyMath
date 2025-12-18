// ============================================
// FotbollsMatte - Football Math Game
// ============================================

// Famous football players with their teams and nationalities
const players = [
    { name: "Lionel Messi", team: "Inter Miami", nation: "Argentina", number: 10 },
    { name: "Cristiano Ronaldo", team: "Al-Nassr", nation: "Portugal", number: 7 },
    { name: "Erling Haaland", team: "Manchester City", nation: "Norge", number: 9 },
    { name: "Kylian Mbappé", team: "Real Madrid", nation: "Frankrike", number: 7 },
    { name: "Zlatan Ibrahimović", team: "AC Milan", nation: "Sverige", number: 11 },
    { name: "Neymar Jr", team: "Al-Hilal", nation: "Brasilien", number: 10 },
    { name: "Vinícius Jr", team: "Real Madrid", nation: "Brasilien", number: 7 },
    { name: "Jude Bellingham", team: "Real Madrid", nation: "England", number: 5 },
    { name: "Mohamed Salah", team: "Liverpool", nation: "Egypten", number: 11 },
    { name: "Kevin De Bruyne", team: "Manchester City", nation: "Belgien", number: 17 },
    { name: "Robert Lewandowski", team: "Barcelona", nation: "Polen", number: 9 },
    { name: "Karim Benzema", team: "Al-Ittihad", nation: "Frankrike", number: 9 },
    { name: "Luka Modrić", team: "Real Madrid", nation: "Kroatien", number: 10 },
    { name: "Victor Lindelöf", team: "Manchester United", nation: "Sverige", number: 2 },
    { name: "Alexander Isak", team: "Newcastle", nation: "Sverige", number: 14 },
    { name: "Dejan Kulusevski", team: "Tottenham", nation: "Sverige", number: 21 }
];

// Famous teams with their stats
const teams = [
    { name: "Real Madrid", league: "La Liga", champions: 15, country: "Spanien" },
    { name: "Barcelona", league: "La Liga", champions: 5, country: "Spanien" },
    { name: "Manchester City", league: "Premier League", champions: 1, country: "England" },
    { name: "Bayern München", league: "Bundesliga", champions: 6, country: "Tyskland" },
    { name: "Liverpool", league: "Premier League", champions: 6, country: "England" },
    { name: "AC Milan", league: "Serie A", champions: 7, country: "Italien" },
    { name: "Manchester United", league: "Premier League", champions: 3, country: "England" },
    { name: "Juventus", league: "Serie A", champions: 2, country: "Italien" },
    { name: "PSG", league: "Ligue 1", champions: 0, country: "Frankrike" },
    { name: "Chelsea", league: "Premier League", champions: 2, country: "England" }
];

// Game state
let gameState = {
    difficulty: 'easy',
    currentQuestion: 0,
    totalQuestions: 10,
    playerScore: 0,
    opponentScore: 0,
    correctAnswers: 0,
    wrongAnswers: 0,
    timeLeft: 90,
    timer: null,
    currentAnswer: null,
    currentPlayerName: ''
};

// DOM Elements
const screens = {
    start: document.getElementById('start-screen'),
    game: document.getElementById('game-screen'),
    result: document.getElementById('result-screen')
};

// Initialize the game
document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
});

function setupEventListeners() {
    // Difficulty buttons
    document.querySelectorAll('.difficulty-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            gameState.difficulty = btn.dataset.level;
            startGame();
        });
    });

    // Submit answer
    document.getElementById('submit-btn').addEventListener('click', submitAnswer);
    document.getElementById('answer-input').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') submitAnswer();
    });

    // Result screen buttons
    document.getElementById('play-again-btn').addEventListener('click', () => startGame());
    document.getElementById('home-btn').addEventListener('click', () => showScreen('start'));
}

function showScreen(screenName) {
    Object.values(screens).forEach(screen => screen.classList.remove('active'));
    screens[screenName].classList.add('active');
}

function startGame() {
    // Reset game state
    gameState.currentQuestion = 0;
    gameState.playerScore = 0;
    gameState.opponentScore = 0;
    gameState.correctAnswers = 0;
    gameState.wrongAnswers = 0;
    gameState.timeLeft = 90;

    // Update UI
    updateScoreDisplay();
    document.getElementById('timer').textContent = gameState.timeLeft;
    document.getElementById('total-questions').textContent = gameState.totalQuestions;

    showScreen('game');
    startTimer();
    generateQuestion();
}

function startTimer() {
    if (gameState.timer) clearInterval(gameState.timer);
    
    gameState.timer = setInterval(() => {
        gameState.timeLeft--;
        document.getElementById('timer').textContent = gameState.timeLeft;
        
        if (gameState.timeLeft <= 0) {
            endGame();
        }
    }, 1000);
}

function generateQuestion() {
    const player = players[Math.floor(Math.random() * players.length)];
    const team = teams[Math.floor(Math.random() * teams.length)];
    
    gameState.currentPlayerName = player.name;
    document.getElementById('current-player').textContent = player.name;
    
    let question, answer;
    
    switch (gameState.difficulty) {
        case 'easy':
            ({ question, answer } = generateEasyQuestion(player, team));
            break;
        case 'medium':
            ({ question, answer } = generateMediumQuestion(player, team));
            break;
        case 'hard':
            ({ question, answer } = generateHardQuestion(player, team));
            break;
    }
    
    gameState.currentAnswer = answer;
    document.getElementById('question-text').textContent = question;
    document.getElementById('answer-input').value = '';
    document.getElementById('answer-input').focus();
    document.getElementById('feedback').classList.remove('show', 'correct', 'wrong');
    
    updateProgress();
}

function generateEasyQuestion(player, team) {
    const templates = [
        // Addition questions
        () => {
            const goals1 = Math.floor(Math.random() * 10) + 1;
            const goals2 = Math.floor(Math.random() * 10) + 1;
            return {
                question: `⚽ ${player.name} gjorde ${goals1} mål i första matchen och ${goals2} mål i andra matchen. Hur många mål gjorde han totalt?`,
                answer: goals1 + goals2
            };
        },
        () => {
            const fans1 = Math.floor(Math.random() * 50) + 10;
            const fans2 = Math.floor(Math.random() * 50) + 10;
            return {
                question: `🏟️ ${team.name} hade ${fans1} fans på ena läktaren och ${fans2} fans på andra. Hur många fans var det totalt?`,
                answer: fans1 + fans2
            };
        },
        () => {
            const assists = Math.floor(Math.random() * 10) + 1;
            const goals = Math.floor(Math.random() * 10) + 1;
            return {
                question: `📊 ${player.name} hade ${assists} assist och ${goals} mål denna säsong. Hur många poäng bidrog han med totalt?`,
                answer: assists + goals
            };
        },
        // Subtraction questions
        () => {
            const total = Math.floor(Math.random() * 30) + 20;
            const used = Math.floor(Math.random() * 15) + 5;
            return {
                question: `🎽 ${team.name} hade ${total} tröjor. De sålde ${used} stycken. Hur många tröjor har de kvar?`,
                answer: total - used
            };
        },
        () => {
            const goals = Math.floor(Math.random() * 20) + 15;
            const missed = Math.floor(Math.random() * 10) + 3;
            return {
                question: `⚽ ${player.name} sköt ${goals} skott på mål. ${missed} av dem gick utanför. Hur många träffade målet?`,
                answer: goals - missed
            };
        },
        () => {
            const players1 = 11;
            const redCards = Math.floor(Math.random() * 3) + 1;
            return {
                question: `🟥 ${team.name} startade med ${players1} spelare men fick ${redCards} röda kort. Hur många spelare har de kvar på plan?`,
                answer: players1 - redCards
            };
        }
    ];
    
    return templates[Math.floor(Math.random() * templates.length)]();
}

function generateMediumQuestion(player, team) {
    const templates = [
        // Multiplication questions
        () => {
            const goalsPerMatch = Math.floor(Math.random() * 4) + 1;
            const matches = Math.floor(Math.random() * 6) + 3;
            return {
                question: `⚽ ${player.name} gör ${goalsPerMatch} mål per match. Hur många mål gör han på ${matches} matcher?`,
                answer: goalsPerMatch * matches
            };
        },
        () => {
            const rows = Math.floor(Math.random() * 8) + 3;
            const seats = Math.floor(Math.random() * 10) + 5;
            return {
                question: `🏟️ ${team.name}s läktare har ${rows} rader med ${seats} platser per rad. Hur många platser finns det?`,
                answer: rows * seats
            };
        },
        () => {
            const price = Math.floor(Math.random() * 5) + 2;
            const tickets = Math.floor(Math.random() * 8) + 2;
            return {
                question: `🎫 En biljett till ${team.name}s match kostar ${price}0 kr. Vad kostar ${tickets} biljetter?`,
                answer: price * 10 * tickets
            };
        },
        () => {
            const trophies = Math.floor(Math.random() * 5) + 2;
            const weight = Math.floor(Math.random() * 5) + 3;
            return {
                question: `🏆 ${player.name} vann ${trophies} pokaler. Varje pokal väger ${weight} kg. Hur mycket väger alla pokaler tillsammans?`,
                answer: trophies * weight
            };
        },
        () => {
            const seasons = Math.floor(Math.random() * 5) + 2;
            const goalsPerSeason = Math.floor(Math.random() * 15) + 10;
            return {
                question: `📈 ${player.name} gjorde ${goalsPerSeason} mål per säsong i ${seasons} säsonger. Hur många mål totalt?`,
                answer: seasons * goalsPerSeason
            };
        },
        () => {
            const teams_count = Math.floor(Math.random() * 5) + 3;
            const players_per = 11;
            return {
                question: `👥 I en turnering spelar ${teams_count} lag. Varje lag har ${players_per} spelare på planen. Hur många spelare är på planen totalt om alla lag spelar?`,
                answer: teams_count * players_per
            };
        }
    ];
    
    return templates[Math.floor(Math.random() * templates.length)]();
}

function generateHardQuestion(player, team) {
    const templates = [
        // Mixed operations
        () => {
            const goals1 = Math.floor(Math.random() * 5) + 3;
            const goals2 = Math.floor(Math.random() * 5) + 2;
            const matches = Math.floor(Math.random() * 3) + 2;
            return {
                question: `⚽ ${player.name} gjorde ${goals1} mål och ${player.name === "Messi" ? "Ronaldo" : "Messi"} gjorde ${goals2} mål per match i ${matches} matcher. Hur många mål gjorde de tillsammans?`,
                answer: (goals1 + goals2) * matches
            };
        },
        () => {
            const total = Math.floor(Math.random() * 50) + 30;
            const sold = Math.floor(Math.random() * 3) + 2;
            const perDay = Math.floor(Math.random() * 8) + 3;
            return {
                question: `🎽 ${team.name} hade ${total} tröjor. De sålde ${perDay} tröjor per dag i ${sold} dagar. Hur många har de kvar?`,
                answer: total - (sold * perDay)
            };
        },
        () => {
            const ticketPrice = Math.floor(Math.random() * 10) + 5;
            const numTickets = Math.floor(Math.random() * 5) + 2;
            const discount = Math.floor(Math.random() * 20) + 10;
            return {
                question: `🎫 ${numTickets} biljetter till ${team.name} kostar ${ticketPrice * numTickets}0 kr. Du får ${discount}0 kr rabatt. Vad betalar du?`,
                answer: (ticketPrice * numTickets * 10) - (discount * 10)
            };
        },
        () => {
            const goalsH1 = Math.floor(Math.random() * 4) + 1;
            const goalsH2 = Math.floor(Math.random() * 4) + 1;
            const opponent = Math.floor(Math.random() * 3) + 1;
            return {
                question: `⚽ ${team.name} gjorde ${goalsH1} mål i första halvlek och ${goalsH2} i andra. Motståndaren gjorde ${opponent} mål. Med hur många mål vann ${team.name}?`,
                answer: (goalsH1 + goalsH2) - opponent
            };
        },
        () => {
            const seasons = Math.floor(Math.random() * 3) + 2;
            const goalsPerSeason = Math.floor(Math.random() * 10) + 15;
            const injuries = Math.floor(Math.random() * 5) + 3;
            return {
                question: `📊 ${player.name} gjorde ${goalsPerSeason} mål per säsong i ${seasons} säsonger, men missade ${injuries} mål p.g.a. skador. Hur många mål gjorde han totalt?`,
                answer: (goalsPerSeason * seasons) - injuries
            };
        },
        () => {
            const teams1 = Math.floor(Math.random() * 4) + 2;
            const teams2 = Math.floor(Math.random() * 3) + 2;
            const playersPerTeam = 11;
            return {
                question: `🏆 I Champions League spelade ${teams1} lag från Spanien och ${teams2} lag från England. Hur många spelare var på planen totalt om alla lag spelade samtidigt?`,
                answer: (teams1 + teams2) * playersPerTeam
            };
        },
        () => {
            const hours = Math.floor(Math.random() * 3) + 2;
            const perHour = Math.floor(Math.random() * 20) + 10;
            const breaks = Math.floor(Math.random() * 2) + 1;
            const breakMins = Math.floor(Math.random() * 10) + 5;
            return {
                question: `🏃 ${player.name} tränade i ${hours} timmar och brände ${perHour} kalorier per timme. Han tog ${breaks} paus(er) på ${breakMins} min. Hur många kalorier brände han under träningen?`,
                answer: hours * perHour
            };
        },
        () => {
            const champions = team.champions;
            const otherTeam = teams.find(t => t.name !== team.name);
            const difference = Math.abs(champions - otherTeam.champions);
            return {
                question: `🏆 ${team.name} har vunnit ${champions} Champions League-titlar och ${otherTeam.name} har vunnit ${otherTeam.champions}. Hur många titlar har de vunnit tillsammans?`,
                answer: champions + otherTeam.champions
            };
        }
    ];
    
    return templates[Math.floor(Math.random() * templates.length)]();
}

function submitAnswer() {
    const input = document.getElementById('answer-input');
    const userAnswer = parseInt(input.value);
    const feedback = document.getElementById('feedback');
    
    if (isNaN(userAnswer)) {
        feedback.textContent = "⚠️ Skriv in ett tal!";
        feedback.className = 'feedback show wrong';
        return;
    }
    
    if (userAnswer === gameState.currentAnswer) {
        // Correct answer
        gameState.correctAnswers++;
        gameState.playerScore++;
        feedback.innerHTML = "⚽ MÅÅÅL! Rätt svar! 🎉";
        feedback.className = 'feedback show correct';
        document.querySelector('.question-box').classList.add('goal-animation');
    } else {
        // Wrong answer
        gameState.wrongAnswers++;
        gameState.opponentScore++;
        feedback.innerHTML = `❌ Tyvärr fel! Rätt svar var ${gameState.currentAnswer}`;
        feedback.className = 'feedback show wrong';
        document.querySelector('.question-box').classList.add('shake');
    }
    
    updateScoreDisplay();
    
    setTimeout(() => {
        document.querySelector('.question-box').classList.remove('goal-animation', 'shake');
        gameState.currentQuestion++;
        
        if (gameState.currentQuestion >= gameState.totalQuestions) {
            endGame();
        } else {
            generateQuestion();
        }
    }, 1500);
}

function updateScoreDisplay() {
    document.getElementById('player-score').textContent = gameState.playerScore;
    document.getElementById('opponent-score').textContent = gameState.opponentScore;
}

function updateProgress() {
    const progress = ((gameState.currentQuestion) / gameState.totalQuestions) * 100;
    document.getElementById('progress').style.width = `${progress}%`;
    document.getElementById('current-question').textContent = gameState.currentQuestion + 1;
}

function endGame() {
    if (gameState.timer) {
        clearInterval(gameState.timer);
    }
    
    showScreen('result');
    
    // Set final scores
    document.getElementById('final-player-score').textContent = gameState.playerScore;
    document.getElementById('final-opponent-score').textContent = gameState.opponentScore;
    
    // Set stats
    document.getElementById('correct-count').textContent = gameState.correctAnswers;
    document.getElementById('wrong-count').textContent = gameState.wrongAnswers;
    
    const accuracy = gameState.totalQuestions > 0 
        ? Math.round((gameState.correctAnswers / gameState.totalQuestions) * 100) 
        : 0;
    document.getElementById('accuracy').textContent = `${accuracy}%`;
    
    // Set result message and animation based on score
    const resultAnimation = document.getElementById('result-animation');
    const resultTitle = document.getElementById('result-title');
    const resultMessage = document.getElementById('result-message');
    
    if (gameState.playerScore > gameState.opponentScore) {
        resultAnimation.textContent = "🏆";
        resultTitle.textContent = "VINST! 🎉";
        resultMessage.textContent = getWinMessage(accuracy);
    } else if (gameState.playerScore < gameState.opponentScore) {
        resultAnimation.textContent = "😢";
        resultTitle.textContent = "Förlust";
        resultMessage.textContent = getLoseMessage(accuracy);
    } else {
        resultAnimation.textContent = "🤝";
        resultTitle.textContent = "Oavgjort!";
        resultMessage.textContent = "Jämn match! Båda lagen kämpade bra. Försök igen för att vinna!";
    }
}

function getWinMessage(accuracy) {
    if (accuracy >= 90) {
        return "🌟 FANTASTISKT! Du spelar som Messi och Ronaldo tillsammans! En riktig superstjärna!";
    } else if (accuracy >= 70) {
        return "⭐ Bra jobbat! Du är på väg att bli en riktig fotbollsmatematiker!";
    } else if (accuracy >= 50) {
        return "👍 Grattis till vinsten! Fortsätt träna så blir du ännu bättre!";
    }
    return "Du vann! Men det finns mer att lära. Fortsätt öva! 💪";
}

function getLoseMessage(accuracy) {
    if (accuracy >= 40) {
        return "Du var nära! Träna lite till så vinner du nästa match! 💪";
    }
    return "Ingen fara! Även Zlatan hade tuffa dagar. Försök igen! ⚽";
}

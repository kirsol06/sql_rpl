DROP TABLE IF EXISTS goals CASCADE;
DROP TABLE IF EXISTS match_events CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS coaches CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS stadiums CASCADE;
DROP TABLE IF EXISTS seasons CASCADE;
DROP TABLE IF EXISTS teams CASCADE;

CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    city TEXT NOT NULL,
    year_founded INTEGER NOT NULL CHECK (year_founded > 1800),
    budget NUMERIC(15,2) NOT NULL CHECK (budget >= 0)
);

CREATE TABLE stadiums (
    stadium_id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL UNIQUE REFERENCES teams(team_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    built_year INTEGER CHECK (built_year > 1800)
);

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    position TEXT NOT NULL CHECK (position IN ('GK', 'DF', 'MF', 'FW')),
    birth_date DATE NOT NULL,
    salary NUMERIC(15,2) NOT NULL CHECK (salary >= 0)
);

CREATE TABLE seasons (
    season_id SERIAL PRIMARY KEY,
    year_start INTEGER NOT NULL UNIQUE,
    year_end INTEGER NOT NULL,
    champion_id INTEGER REFERENCES teams(team_id) ON DELETE SET NULL,
    CHECK (year_end = year_start + 1)
);

CREATE TABLE coaches (
    coach_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    mentor_id INTEGER REFERENCES coaches(coach_id) ON DELETE SET NULL,
    team_id INTEGER NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    salary NUMERIC(15,2) NOT NULL CHECK (salary >= 0)
);

CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    home_team_id INTEGER NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    away_team_id INTEGER NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    match_date DATE NOT NULL,
    season_id INTEGER NOT NULL REFERENCES seasons(season_id) ON DELETE CASCADE,
    stadium_id INTEGER REFERENCES stadiums(stadium_id) ON DELETE SET NULL,
    CHECK (home_team_id <> away_team_id)
);

CREATE TABLE match_events (
    event_id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
    match_id INTEGER NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('goal', 'assist', 'foul', 'yellow_card', 'red_card')),
    minute INTEGER NOT NULL CHECK (minute BETWEEN 1 AND 90),
    description TEXT,
    UNIQUE (player_id, match_id, event_type, minute)
);

CREATE TABLE goals (
    match_id INTEGER NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
    goal_seq INTEGER NOT NULL CHECK (goal_seq > 0),
    player_id INTEGER NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
    is_penalty BOOLEAN NOT NULL DEFAULT FALSE,
    assist_by INTEGER REFERENCES players(player_id) ON DELETE SET NULL,
    PRIMARY KEY (match_id, goal_seq)
);
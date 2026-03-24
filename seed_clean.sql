INSERT INTO teams (name, city, year_founded, budget) VALUES
('Zenit', 'Saint Petersburg', 1925, 50000000),
('Spartak', 'Moscow', 1922, 45000000),
('CSKA', 'Moscow', 1911, 48000000),
('Krasnodar', 'Krasnodar', 2008, 40000000);

INSERT INTO stadiums (team_id, name, capacity, built_year) VALUES
(1, 'Gazprom Arena', 45360, 2017),
(2, 'Lukoil Arena', 45360, 2014),
(3, 'VEB Arena', 30244, 2016),
(4, 'Krasnodar Stadium', 35179, 2016);

INSERT INTO seasons (year_start, year_end, champion_id) VALUES
(2022, 2023, 1),
(2023, 2024, 1);

INSERT INTO players (team_id, name, position, birth_date, salary) VALUES
(1, 'Artem Dzyuba', 'FW', '1988-08-22', 3000000),
(1, 'Malcom', 'FW', '1997-02-26', 2500000),
(1, 'Claudinho', 'MF', '1997-01-28', 2000000),
(1, 'Douglas Santos', 'DF', '1994-03-22', 1900000),
(1, 'Denis Adamov', 'GK', '1998-02-20', 800000),

(2, 'Alexander Sobolev', 'FW', '1997-03-07', 1500000),
(2, 'Quincy Promes', 'FW', '1992-01-04', 3500000),
(2, 'Ruslan Litvinov', 'MF', '2001-08-18', 900000),
(2, 'Georgiy Dzhikiya', 'DF', '1993-11-21', 2000000),
(2, 'Alexander Maksimenko', 'GK', '1998-03-19', 1200000),

(3, 'Fedor Chalov', 'FW', '1998-04-10', 1800000),
(3, 'Jorge Carrascal', 'MF', '1998-05-25', 1600000),
(3, 'Mario Fernandes', 'DF', '1990-09-19', 2200000),
(3, 'Igor Akinfeev', 'GK', '1986-04-08', 2500000),

(4, 'John Cordoba', 'FW', '1993-05-11', 2000000),
(4, 'Alexander Chernikov', 'MF', '1999-02-26', 700000),
(4, 'Sergey Petrov', 'DF', '1991-01-02', 1200000),
(4, 'Matvey Safonov', 'GK', '1999-02-25', 1400000);

INSERT INTO coaches (name, mentor_id, team_id, start_date, salary) VALUES
('Sergey Semak', NULL, 1, '2018-05-29', 3000000),
('Guillermo Abascal', NULL, 2, '2022-06-10', 2500000),
('Vladimir Fedotov', NULL, 3, '2022-06-15', 2200000),
('Murad Musaev', NULL, 4, '2024-03-13', 2000000);

INSERT INTO matches (home_team_id, away_team_id, match_date, season_id, stadium_id) VALUES
(1, 2, '2023-07-22', 2, 1),
(3, 4, '2023-07-23', 2, 3),
(2, 1, '2023-11-05', 2, 2),
(4, 3, '2023-11-06', 2, 4);

INSERT INTO goals (match_id, goal_seq, player_id, is_penalty, assist_by) VALUES
(1, 1, 1, FALSE, 2),
(1, 2, 6, FALSE, 7),
(1, 3, 2, FALSE, NULL),
(2, 1, 11, TRUE, NULL),
(2, 2, 15, FALSE, 16),
(3, 1, 7, TRUE, NULL),
(3, 2, 2, FALSE, 3),
(4, 1, 15, FALSE, 16),
(4, 2, 11, FALSE, 12);

INSERT INTO match_events (player_id, match_id, event_type, minute, description) VALUES
(1, 1, 'goal', 23, 'Goal after cross'),
(6, 1, 'goal', 45, 'Shot from edge'),
(2, 1, 'goal', 67, 'Long shot'),
(7, 1, 'assist', 45, 'Accurate pass'),
(4, 1, 'foul', 34, 'Hard tackle'),

(11, 2, 'goal', 12, 'Penalty scored'),
(15, 2, 'goal', 55, 'Shot after cross'),
(13, 2, 'yellow_card', 78, 'Stopping attack'),

(7, 3, 'goal', 24, 'Penalty'),
(2, 3, 'goal', 72, 'Shot from distance'),
(3, 3, 'assist', 72, 'Pass into space'),

(15, 4, 'goal', 51, 'Header'),
(11, 4, 'goal', 69, 'Low shot'),
(16, 4, 'assist', 51, 'Wing cross');
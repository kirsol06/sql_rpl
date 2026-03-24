-- 1. Топ бомбардиров
SELECT
    p.name AS player_name,
    t.name AS team_name,
    COUNT(*) AS goals_scored
FROM goals g
JOIN players p ON g.player_id = p.player_id
JOIN teams t ON p.team_id = t.team_id
GROUP BY p.player_id, p.name, t.name
ORDER BY goals_scored DESC, player_name;

-- 2. Топ ассистентов
SELECT
    p.name AS player_name,
    t.name AS team_name,
    COUNT(*) AS assists
FROM goals g
JOIN players p ON g.assist_by = p.player_id
JOIN teams t ON p.team_id = t.team_id
WHERE g.assist_by IS NOT NULL
GROUP BY p.player_id, p.name, t.name
ORDER BY assists DESC, player_name;

-- 3. Результативность команд: матчи, голы, голы за матч
WITH team_matches AS (
    SELECT home_team_id AS team_id, match_id FROM matches
    UNION ALL
    SELECT away_team_id AS team_id, match_id FROM matches
),
team_goals AS (
    SELECT
        p.team_id,
        g.match_id,
        COUNT(*) AS goals_in_match
    FROM goals g
    JOIN players p ON g.player_id = p.player_id
    GROUP BY p.team_id, g.match_id
)
SELECT
    t.name AS team_name,
    COUNT(DISTINCT tm.match_id) AS matches_played,
    COALESCE(SUM(tg.goals_in_match), 0) AS total_goals,
    ROUND(COALESCE(SUM(tg.goals_in_match), 0)::NUMERIC / COUNT(DISTINCT tm.match_id), 2) AS goals_per_match
FROM teams t
JOIN team_matches tm ON t.team_id = tm.team_id
LEFT JOIN team_goals tg
    ON tg.team_id = tm.team_id
   AND tg.match_id = tm.match_id
GROUP BY t.team_id, t.name
ORDER BY goals_per_match DESC, total_goals DESC;

-- 4. Домашняя и гостевая результативность
WITH goals_by_team_match AS (
    SELECT
        p.team_id,
        g.match_id,
        COUNT(*) AS goals
    FROM goals g
    JOIN players p ON g.player_id = p.player_id
    GROUP BY p.team_id, g.match_id
)
SELECT
    t.name AS team_name,
    COUNT(DISTINCT CASE WHEN m.home_team_id = t.team_id THEN m.match_id END) AS home_matches,
    COALESCE(SUM(CASE WHEN m.home_team_id = t.team_id THEN gbtm.goals END), 0) AS home_goals,
    COUNT(DISTINCT CASE WHEN m.away_team_id = t.team_id THEN m.match_id END) AS away_matches,
    COALESCE(SUM(CASE WHEN m.away_team_id = t.team_id THEN gbtm.goals END), 0) AS away_goals
FROM teams t
LEFT JOIN matches m
    ON t.team_id IN (m.home_team_id, m.away_team_id)
LEFT JOIN goals_by_team_match gbtm
    ON gbtm.match_id = m.match_id
   AND gbtm.team_id = t.team_id
GROUP BY t.team_id, t.name
ORDER BY home_goals DESC, away_goals DESC;

-- 5. Зарплатная структура команд
SELECT
    t.name AS team_name,
    COUNT(p.player_id) AS players_count,
    ROUND(AVG(p.salary), 2) AS avg_salary,
    MIN(p.salary) AS min_salary,
    MAX(p.salary) AS max_salary,
    SUM(p.salary) AS total_payroll
FROM teams t
JOIN players p ON t.team_id = p.team_id
GROUP BY t.team_id, t.name
ORDER BY total_payroll DESC;

-- 6. Ранжирование игроков по зарплате внутри команды
SELECT
    t.name AS team_name,
    p.name AS player_name,
    p.position,
    p.salary,
    RANK() OVER (PARTITION BY p.team_id ORDER BY p.salary DESC) AS salary_rank_in_team
FROM players p
JOIN teams t ON p.team_id = t.team_id
ORDER BY t.name, salary_rank_in_team, p.name;

-- 7. Анализ зарплат по позициям
SELECT DISTINCT
    position,
    COUNT(*) OVER (PARTITION BY position) AS players_count,
    ROUND(AVG(salary) OVER (PARTITION BY position), 2) AS avg_salary,
    ROUND(MIN(salary) OVER (PARTITION BY position), 2) AS min_salary,
    ROUND(MAX(salary) OVER (PARTITION BY position), 2) AS max_salary
FROM players
ORDER BY avg_salary DESC;

-- 8. Средний возраст игроков по командам
SELECT
    t.name AS team_name,
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date))), 1) AS avg_age,
    MIN(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date))) AS min_age,
    MAX(EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.birth_date))) AS max_age,
    COUNT(*) AS players_count
FROM teams t
JOIN players p ON t.team_id = p.team_id
GROUP BY t.team_id, t.name
ORDER BY avg_age;

-- 9. Самые дисциплинарно проблемные игроки
SELECT
    t.name AS team_name,
    p.name AS player_name,
    COUNT(*) AS disciplinary_events
FROM match_events me
JOIN players p ON me.player_id = p.player_id
JOIN teams t ON p.team_id = t.team_id
WHERE me.event_type IN ('foul', 'yellow_card', 'red_card')
GROUP BY t.name, p.name
ORDER BY disciplinary_events DESC, player_name;

-- 10. Команды с бюджетом выше среднего
SELECT
    t.name AS team_name,
    t.city,
    t.budget,
    s.name AS stadium_name,
    s.capacity,
    ROUND((SELECT AVG(budget) FROM teams), 2) AS league_avg_budget
FROM teams t
JOIN stadiums s ON t.team_id = s.team_id
WHERE t.budget > (SELECT AVG(budget) FROM teams)
ORDER BY t.budget DESC;

-- 11. Распределение событий по таймам
SELECT
    CASE
        WHEN minute <= 45 THEN 'Первый тайм'
        ELSE 'Второй тайм'
    END AS half,
    COUNT(*) AS events_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM match_events
GROUP BY
    CASE
        WHEN minute <= 45 THEN 'Первый тайм'
        ELSE 'Второй тайм'
    END
ORDER BY events_count DESC;

-- 12. Связь бюджета и результативности команд
WITH team_stats AS (
    SELECT
        t.team_id,
        t.name,
        t.budget,
        COUNT(DISTINCT tm.match_id) AS matches_played,
        COALESCE(SUM(gm.goals), 0) AS total_goals
    FROM teams t
    JOIN (
        SELECT home_team_id AS team_id, match_id FROM matches
        UNION ALL
        SELECT away_team_id AS team_id, match_id FROM matches
    ) tm ON tm.team_id = t.team_id
    LEFT JOIN (
        SELECT
            p.team_id,
            g.match_id,
            COUNT(*) AS goals
        FROM goals g
        JOIN players p ON g.player_id = p.player_id
        GROUP BY p.team_id, g.match_id
    ) gm
      ON gm.team_id = t.team_id
     AND gm.match_id = tm.match_id
    GROUP BY t.team_id, t.name, t.budget
)
SELECT
    name AS team_name,
    budget,
    matches_played,
    total_goals,
    ROUND(total_goals::NUMERIC / matches_played, 2) AS goals_per_match
FROM team_stats
ORDER BY budget DESC;

-- 13. Игроки, которые и забивали, и ассистировали
SELECT
    p.name AS player_name,
    t.name AS team_name
FROM players p
JOIN teams t ON p.team_id = t.team_id
WHERE p.player_id IN (SELECT player_id FROM goals)
  AND p.player_id IN (SELECT assist_by FROM goals WHERE assist_by IS NOT NULL)
ORDER BY team_name, player_name;

-- 14. Тренеры и их наставники
SELECT
    c.name AS coach_name,
    t.name AS team_name,
    c.salary,
    c.start_date,
    mc.name AS mentor_name
FROM coaches c
JOIN teams t ON c.team_id = t.team_id
LEFT JOIN coaches mc ON c.mentor_id = mc.coach_id
ORDER BY c.salary DESC, coach_name;
USE IPL;

SELECT * FROM IPL_USER;   
SELECT * FROM IPL_BIDDER_DETAILS;
SELECT * FROM ipl_bidding_details;
SELECT * FROM ipl_bidder_points;
SELECT * FROM ipl_tournament;
SELECT * FROM ipl_match;
SELECT * FROM ipl_match_schedule;
SELECT * FROM ipl_stadium;
SELECT * FROM ipl_team;
SELECT * FROM ipl_team_players;
SELECT * FROM ipl_player;
SELECT * FROM ipl_team_standings;


##### Questions – Write SQL queries to get data for following requirements: #####


/*
1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.
*/
SELECT BD.BIDDER_ID, BI.BIDDER_NAME, COUNT(BD.BID_STATUS) NO_OF_WINS, BP.NO_OF_BIDS, 
CONCAT(ROUND((COUNT(BD.BID_STATUS) / BP.NO_OF_BIDS) * 100, 2), '%') BID_WIN_PERCENTAGE 
FROM ipl_bidder_details BI 
JOIN ipl_bidding_details BD 
ON BI.BIDDER_ID = BD.BIDDER_ID
JOIN ipl_bidder_points BP 
ON BD.BIDDER_ID = BP.BIDDER_ID 
WHERE BD.BID_STATUS = 'WON'
GROUP BY BD.BIDDER_ID, BI.BIDDER_NAME, BP.NO_OF_BIDS 
ORDER BY (COUNT(BD.BID_STATUS) / BP.NO_OF_BIDS) * 100 DESC;


/*
2. Display the number of matches conducted at each stadium with stadium name, city from the database.
*/
SELECT ST.STADIUM_ID, ST.STADIUM_NAME, ST.CITY, COUNT(MS.MATCH_ID) NO_OF_MATCHES_CONDUCTED
FROM ipl_stadium ST 
JOIN ipl_match_schedule MS 
ON ST.STADIUM_ID = MS.STADIUM_ID 
WHERE STATUS = 'Completed' 
GROUP BY ST.STADIUM_ID, ST.STADIUM_NAME, ST.CITY;


/*
3. In a given stadium, what is the percentage of wins by a team which has won the toss?
*/
UPDATE IPL_MATCH SET MATCH_WINNER=2 WHERE MATCH_ID=1054;   # Updating correct value as whether Team_Id1 or Team_Id2 won the match similar to the remaining records
UPDATE IPL_MATCH SET MATCH_WINNER=2 WHERE MATCH_ID=1058;   # Updating correct value as whether Team_Id1 or Team_Id2 won the match similar to the remaining records
UPDATE IPL_MATCH SET MATCH_WINNER=2 WHERE MATCH_ID=1056;   # Updating correct value as whether Team_Id1 or Team_Id2 won the match similar to the remaining records
UPDATE IPL_MATCH SET MATCH_WINNER=2 WHERE MATCH_ID=1057;   # Updating correct value as whether Team_Id1 or Team_Id2 won the match similar to the remaining records


SELECT ST.STADIUM_ID, ST.STADIUM_NAME, T.TEAM_ID, T.TEAM_NAME, 
CASE WHEN M.TOSS_WINNER = 1 THEN M.TEAM_ID1 
ELSE M.TEAM_ID2 
END AS TEAM_WHICH_WON_TOSS, 
CASE WHEN M.MATCH_WINNER = 1 THEN M.TEAM_ID1 
ELSE M.TEAM_ID2 
END AS TEAM_WHICH_WON_MATCH, 
SUM(TS.MATCHES_WON) NO_OF_MATCHES_WON, SUM(TS.MATCHES_PLAYED) NO_OF_MATCHES_PLAYED, 
CONCAT(ROUND((SUM(TS.MATCHES_WON) / SUM(TS.MATCHES_PLAYED)) * 100, 2), '%') TEAM_WIN_PERCENTAGE
FROM ipl_stadium ST 
JOIN ipl_match_schedule MS 
ON ST.STADIUM_ID = MS.STADIUM_ID 
JOIN ipl_match M 
ON M.MATCH_ID = MS.MATCH_ID 
JOIN ipl_team_standings TS 
ON TS.TOURNMT_ID = MS.TOURNMT_ID 
JOIN ipl_team T 
ON T.TEAM_ID = TS.TEAM_ID 
WHERE M.TOSS_WINNER = M.MATCH_WINNER
GROUP BY ST.STADIUM_ID, ST.STADIUM_NAME, T.TEAM_ID, T.TEAM_NAME, TEAM_WHICH_WON_TOSS, TEAM_WHICH_WON_MATCH
HAVING T.TEAM_ID = TEAM_WHICH_WON_TOSS; 


/*
4. Show the total bids along with bid team and team name.
*/
SELECT BD.BID_TEAM BID_TEAM_ID, T.TEAM_NAME, COUNT(BD.BID_STATUS) TOTAL_BIDS
FROM ipl_bidding_details BD 
JOIN ipl_team T 
ON BD.BID_TEAM = T.TEAM_ID
WHERE BD.BID_STATUS != 'Cancelled' 
group by BD.BID_TEAM, T.TEAM_NAME;


/*
5. Show the team id who won the match as per the win details.
*/
SELECT M.MATCH_ID, MS.MATCH_TYPE, T.TEAM_ID, T.TEAM_NAME, M.WIN_DETAILS  
FROM ipl_match M 
JOIN ipl_match_schedule MS
ON M.MATCH_ID = MS.MATCH_ID 
JOIN ipl_team_standings TS 
ON MS.TOURNMT_ID = TS.TOURNMT_ID
JOIN ipl_team T 
ON TS.TEAM_ID = T.TEAM_ID 
WHERE substring(T.REMARKS,1,2) = substring(M.WIN_DETAILS,6,2);


/*
6. Display total matches played, total matches won and total matches lost by team along with its team name.
*/
SELECT T.TEAM_ID, T.TEAM_NAME, 
SUM(TS.MATCHES_PLAYED) TOTAL_MATCHES_PLAYED, SUM(TS.MATCHES_WON) TOTAL_MATCHES_WON, SUM(TS.MATCHES_LOST) TOTAL_MATCHES_LOST
FROM ipl_team T 
JOIN ipl_team_standings TS 
ON T.TEAM_ID = TS.TEAM_ID 
GROUP BY T.TEAM_ID, T.TEAM_NAME;


/*
7. Display the bowlers for Mumbai Indians team.
*/
SELECT P.PLAYER_ID, P.PLAYER_NAME, T.TEAM_ID, T.TEAM_NAME, TP.PLAYER_ROLE 
FROM ipl_team T 
JOIN ipl_team_players TP 
ON T.TEAM_ID = TP.TEAM_ID 
JOIN ipl_player P 
ON TP.PLAYER_ID = P.PLAYER_ID 
WHERE T.TEAM_NAME LIKE '%MUMBAI%' AND TP.PLAYER_ROLE IN ('All-Rounder', 'Bowler');


/*
8. How many all-rounders are there in each team, Display the teams with more than 4 
all-rounder in descending order.
*/
SELECT T.TEAM_ID, T.TEAM_NAME, COUNT(TP.PLAYER_ROLE) NO_OF_ALL_ROUNDERS
FROM ipl_team T 
JOIN ipl_team_players TP 
ON T.TEAM_ID = TP.TEAM_ID 
JOIN ipl_player P 
ON TP.PLAYER_ID = P.PLAYER_ID 
WHERE TP.PLAYER_ROLE LIKE '%ALL%' 
GROUP BY T.TEAM_ID, T.TEAM_NAME;

SELECT T.TEAM_ID, T.TEAM_NAME, COUNT(TP.PLAYER_ROLE) NO_OF_ALL_ROUNDERS
FROM ipl_team T 
JOIN ipl_team_players TP 
ON T.TEAM_ID = TP.TEAM_ID 
JOIN ipl_player P 
ON TP.PLAYER_ID = P.PLAYER_ID 
WHERE TP.PLAYER_ROLE LIKE '%ALL%' 
GROUP BY T.TEAM_ID, T.TEAM_NAME 
HAVING COUNT(TP.PLAYER_ROLE) > 4 
ORDER BY NO_OF_ALL_ROUNDERS DESC;
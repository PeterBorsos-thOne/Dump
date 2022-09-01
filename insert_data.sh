#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# --username=postgres --dbname=worldcuptest

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS=',' read YEAR ROUND WIN OPP WG OG
do
  if [[ $YEAR != "year" ]]
  then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
    if [[ -z $TEAM_ID ]]
    then
      INS_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WIN')")
      if [[ $INS_NAME == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WIN
      fi
    fi

    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP'")
    if [[ -z $TEAM_ID ]]
    then
      INS_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPP')")
      if [[ $INS_NAME == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPP
      fi
    fi
  fi
done
echo -e "\n$($PSQL "SELECT * FROM teams;")"


#insert into games
cat games.csv | while IFS=',' read YEAR ROUND WIN OPP WG OG
do
  if [[ $YEAR != "year" ]]
    then
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP'")
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR and round = '$ROUND' AND winner_id = $WIN_ID AND opponent_id = $OPP_ID AND winner_goals = $WG AND opponent_goals = $OG")
    
    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WG, $OG);")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR, $ROUND, $WIN, $OPP, $WG, $OG
      fi
    fi

  fi
done
echo -e "\n$($PSQL "SELECT * FROM games;")"

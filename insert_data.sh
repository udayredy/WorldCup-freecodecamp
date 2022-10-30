#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if [[ $YEAR != "year" && $ROUND != "round" &&
          $WINNER != "winner" && $OPPONENT != "opponent" &&
          $WINNER_GOALS != "winner_goals" && $OPPONENT_GOALS != "opponent_goals" ]]
    then
        TEAM_ID_WIN=$($PSQL "SELECT team_id from teams where name='$WINNER'")
        TEAM_ID_OPP=$($PSQL "SELECT team_id from teams where name='$OPPONENT'")
        if [[ -z $TEAM_ID_WIN ]]
        then
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) values('$WINNER')")
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $WINNER
            fi
            TEAM_ID_WIN=$($PSQL "SELECT team_id from teams where name='$WINNER'")
        fi
        if [[ -z $TEAM_ID_OPP ]]
            then
                INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) values('$OPPONENT')")
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $OPPONENT
            fi    
            TEAM_ID_OPP=$($PSQL "SELECT team_id from teams where name='$OPPONENT'")
        fi
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES('$YEAR', '$ROUND', '$WINNER_GOALS', '$OPPONENT_GOALS', '$TEAM_ID_WIN', '$TEAM_ID_OPP')")
        if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
        then
            echo Inserted into games, $ROUND: $WINNER $WINNER_GOALS:$OPPONENT_GOALS $OPPONENT
        fi
    fi
done

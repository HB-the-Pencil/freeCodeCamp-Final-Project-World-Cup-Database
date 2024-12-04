#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Get winner_id.
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # If it doesn't exist, insert it and get the new id.
    if [[ -z $WINNER_ID ]]
    then
      WINNER_INSERT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")

      if [[ $WINNER_INSERT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams [$WINNER]"
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      fi
    fi

    # Get opponent id.
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If it doesn't exist, insert it and get the new id.
    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_INSERT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")

      if [[ $OPPONENT_INSERT == "INSERT 0 1" ]]
      then
        echo "Inserted into teams [$OPPONENT]"
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      fi
    fi

    # Insert values into games table.
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games [Winner: $WINNER, Opponent: $OPPONENT, Score: $WINNER_GOALS-$OPPONENT_GOALS]"
    fi
  fi
done
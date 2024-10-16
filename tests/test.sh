#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <server_host> <server_port> <pattern> <num_clients> <delay>"
    echo "Example: $0 localhost 12345 \"happy\" 10 0"
    exit 1
fi

SERVER_HOST=$1
SERVER_PORT=$2
PATTERN=$3
NUM_CLIENTS=$4
DELAY=$5

echo "Checking if port $SERVER_PORT is in use..."
lsof -ti:$SERVER_PORT | xargs kill -9 2>/dev/null

echo "Starting server on $SERVER_HOST:$SERVER_PORT with pattern \"$PATTERN\"..."
./assignment3.py -l $SERVER_PORT -p "$PATTERN" &
SERVER_PID=$!

stop() {
    echo "--- stop ---"
    kill -9 $SERVER_PID
}
# 监听 SIGTERM 和 SIGINT 信号
trap stop SIGINT SIGTERM

sleep 2

TEXT_FILES=(
    "books/book1.txt"
    "books/book2.txt"
    "books/book3.txt"
    "books/book4.txt"
    "books/book5.txt"
    "books/book6.txt"
    "books/book7.txt"
    "books/book8.txt"
    "books/book9.txt"
    "books/book10.txt"
)

if [ "$NUM_CLIENTS" -gt "${#TEXT_FILES[@]}" ]; then
    echo "Warning: Not enough text files for the number of clients requested."
    echo "Adjusting number of clients to ${#TEXT_FILES[@]}."
    NUM_CLIENTS=${#TEXT_FILES[@]}
fi

echo "Simulating $NUM_CLIENTS clients..."

send_data() {
    FILE=$1
    nc $SERVER_HOST $SERVER_PORT -i $DELAY < "$FILE" &
}

for (( i=0; i<$NUM_CLIENTS; i++ ))
do
    FILE=${TEXT_FILES[$i]}
    if [ ! -f "$FILE" ]; then
        echo "Error: File $FILE does not exist."
        continue
    fi
    echo "Client $((i+1)): Sending $FILE"
    send_data "$FILE"
done

wait

echo "Stopping server..."

echo "Test completed."

docker rm -f restheart mongodb


# Create directories if they don't exist
mkdir data

docker run -d \
  -e MONGO_INITDB_ROOT_USERNAME='restheart' \
  -e MONGO_INITDB_ROOT_PASSWORD='R3ste4rt!' \
  --name mongodb \
  -v "$PWD/data:/data/db" \
  -v "$PWD/import:/home" \
  mongo:3.6 --bind_ip_all --auth

MONGODB_CONTAINER_NAME="mongodb"

# Function to check if MongoDB is ready
mongodb_ready() {
  docker exec "${MONGODB_CONTAINER_NAME}" mongo --eval "db.stats()" > /dev/null 2>&1
}

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
while ! mongodb_ready; do
  sleep 5
done
echo "MongoDB is ready!"

docker exec mongodb mongoimport \
  -u restheart -p R3ste4rt! \
  --authenticationDatabase admin \
  --db myflix --collection videos --drop \
  --file /home/videos.json

docker exec mongodb mongoimport \
  -u restheart -p R3ste4rt! \
  --authenticationDatabase admin \
  --db myflix --collection categories --drop \
  --file /home/categories.json
docker run -d -p 80:8080 --name restheart --link mongodb:mongodb softinstigate/restheart:4.1.0

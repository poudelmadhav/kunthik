# Docker Setup

## Build image
```shell
docker build --platform linux/amd64 -t kunthik .
```

## Set required environment variables
```shell
export SECRET_KEY_BASE="$(rails secret)"
export DATABASE_URL="postgresql://postgres:password@localhost:5432/kunthik_development"
```

## Run container
```shell
docker run --rm -it -p 3000:3000 --name=kunthik-container \
  -e DATABASE_URL=$DATABASE_URL \
  -e SECRET_KEY_BASE=$RAILS_SECRET_KEY \
  kunthik
```

## Push Docker Image to Docker Hub
```shell
docker tag kunthik:latest paudelmadhav/kunthik:latest
docker push paudelmadhav/kunthik:latest
```

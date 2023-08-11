.PHONY: all build test run
# build: 0629

# export sh1 = $$(git rev-parse HEAD)
# export sh2 = $$(echo $(sh1) | cut -c 1-7)

	
test: 
	go test ./...

build: test
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o florentia-api-exe .

run: build
	go run .

push: build
	mkdir ./build
	cp ./florentia-api-exe ./build/florentia-api-exe
	cd build && zip -r florentia-api.zip .
	cd build && aws s3 cp florentia-api.zip s3://florentia-lambda-functions/florentia-api/${GITHUB_SHA}/florentia-api.zip

generate-jwt-keys:
	ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key

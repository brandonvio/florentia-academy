.PHONY: all build test run plan deploy

deploy:
	terraform init
	terraform validate
	terraform plan -var "github_sha=${GITHUB_SHA}"
	terraform apply -var "github_sha=${GITHUB_SHA}" -auto-approve

plan:
	terraform validate
	terraform plan -var "github_sha=${GITHUB_SHA}"

apply:
	terraform validate
	terraform plan -var "github_sha=${GITHUB_SHA}"
	terraform apply -var "github_sha=${GITHUB_SHA}" -auto-approve
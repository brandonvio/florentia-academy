deploy:
	npm install
	npm run build
	aws s3 sync build/ s3://home.florentia.academy
	aws cloudfront create-invalidation --distribution-id E360BLQ8VPGNR3 --paths "/*"
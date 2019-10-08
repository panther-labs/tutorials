deploy:
	aws cloudformation deploy --stack-name $(stack) --template-file $(tutorial)/cloudformation/$(stack).yml --region $(region) --capabilities CAPABILITY_NAMED_IAM

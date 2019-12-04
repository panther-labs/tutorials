# parameters usage: "--parameter-overrides Key=Value Key2=Value2"
deploy:
	aws cloudformation deploy --stack-name $(stack) --template-file $(tutorial)/cloudformation/$(stack).yml --region $(region) --capabilities CAPABILITY_NAMED_IAM $(parameters)

destroy:
	aws cloudformation delete-stack --stack-name $(stack) --region $(region)

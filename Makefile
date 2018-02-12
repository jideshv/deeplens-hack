
package:
	aws cloudformation package \
	--template-file deeplens-hack.yml \
	--output-template-file deeplens-hack-output.yaml \
	--s3-bucket deeplens-face-detection --profile $(profile)

deploy:
	aws cloudformation deploy \
  --template-file deeplens-hack-output.yaml \
  --stack-name deeplens-face-detection-stack --profile $(profile)

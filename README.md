# Deeplens Hackathon 

Repo for [AWS deeplens hackathon](https://awsdeeplens.devpost.com/)

## Lambda functions

### deeplens face detection

This lambda runs on the deeplens camera and is responsible for the inference that detects faces
in a video stream.
For each face it detects it pushed the croped face image to S3 for further analysis 

### rekognize emotions

This lambda is triggered by a putObject event from the deeplens face detection lambda and calls
[AWS Rekognition](https://aws.amazon.com/rekognition/) to get a list of emotions for each face.
It then stores each emotion's probablity in a DynamoDB table

## Development

Make sure you've created all the required IAM roles when registering your Deeplens camera

### Build

To build the lambda source packages run the following command:

```
make package profile=<your_aws_profile>

```

### Deployment

To deploy the lambda functions run the following command:

```
make deploy profile=<your_aws_profile>

```

Then go to the [deeplens console]() and edit your project deeplensfacedetection version to the latest

Then select the project and deploy it to the device. 

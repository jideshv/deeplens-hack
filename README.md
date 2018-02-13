# Audience Emotion Rekognition 
## Deeplens Hackathon 

One of the challenges with audience measurement systems is that they are heavily reliant on the quality of responses from the survey participants. Our idea is to reduce the overhead involved in recognizing emotions in audiences and also increase reliablity of the measurements at the same time.

The solution involves the use of a DeepLens device to recognize faces using a local infrence and send only the clips of the faces to S3. A lambda monitoring the S3 bucket will then call Rekognition to get the emotions for each face. The data is then fed to DynamoDB for archival purposes and CloudWatch for real time monitoring of the metrics. 

It would not be practial to send the entire frame in real time to rekognition thus the local infrence on the DeepLens makes for a much more optimized solution where outbound bandwidth no longer becomes an issue. This enables the following scenarios that would otherwise not be practical without local infrence: 

*More accurate ratings of households particapting in TV rating groups
*Presenters can measure how their audience reacted to differnet parts of their presentation instead of only relying on written feedback.  Use at re:invent next year?
*Movies and new shows are often screened with audiences that use a dial to share their feelings. This can be augmented with emotion recogintion to get a deeper understanding of how the audience reacted. 

Overall, the power of combining local inference with cloud based deep learning services can make otherwise unpractical measurements incredibly easy.  Below are the techincal details of how all of this works.

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

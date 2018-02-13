# Deep Emotion Audience Rekognition (DEAR)
## Deeplens Hackathon Submission

One of the challenges with audience measurement systems is that they are heavily reliant on the quality of responses from the survey participants. Our idea is to reduce the overhead involved in recognizing emotions in audiences and also increase reliablity of the measurements at the same time.

The solution involves the use of a DeepLens device to recognize faces using a local infrence and send only the clips of the faces to S3. A lambda monitoring the S3 bucket will then call Rekognition to get the emotions for each face. The data is then fed to DynamoDB for archival purposes and CloudWatch for real time monitoring of the metrics. 

It would not be practial to send the entire frame in real time to rekognition thus the local inference on the DeepLens makes for a much more optimized solution where outbound bandwidth no longer becomes an issue. This enables the following scenarios that would otherwise not be practical without local infrence: 

* More accurate ratings of households particapting in TV rating groups
* Presenters can measure how their audience reacted to differnet parts of their presentation instead of only relying on written feedback.  Use at re:invent next year?
* Movies and new shows are often screened with audiences that use a dial to share their feelings. This can be augmented with emotion recogintion to get a deeper understanding of how the audience reacted. 

Overall, the power of combining local inference with cloud based deep learning services can make otherwise unpractical measurements incredibly easy.  Below are the techincal details of how all of this works.

## Lambda functions

### deeplens face detection

This lambda runs on the deeplens camera and is responsible for the inference that detects faces
in a video stream.

For each face it detects it pushed the croped face image to S3 for further analysis 

### rekognize emotions

This lambda is triggered by a putObject event from the deeplens face detection lambda and calls
[AWS Rekognition](https://aws.amazon.com/rekognition/) to get a list of emotions for each face.
It then stores each emotion's probablity in a DynamoDB table as well as send this to CloudWatch
to show realtime data for the event.

## Development and Testing

Setup your deeplens camera and create all the required IAM roles

Create a new project using the **Face Detection** template
We'll be using the pre-built Face Recognition model from the DeepLens templates for our demo. Therefore, we have not included a sperate model json file since that one is available on S3.

Then create the required resources:
* 2 lambda functions
* 1 S3 bucket
* 1 DynamoDB table

Using [AWS Serverless Application Model, or SAM](https://github.com/awslabs/serverless-application-model) deploy the above resources. 

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

### Permissions

The `deeplensFaceDetection` lambda function running on the deeplens camera needs to 
be able to put objects on the S3 bucket you've created above so give it permissions
to the Role created previously when creating a new deeplens project. 

- Make sure it has permissions to putObjects to S3

the `rekognizeEmotions` lambda function needs access to the images on the S3 bucket 
so it can get the emotions, it needs access to AWS Rekognition, access to DynamoDB 
and CloudWatch to push the metrics for the live dashboard

Make sure `rekognizeEmotions` has permissions to:
- S3 bucket 
- DynamoDB Table
- rekognition
- CloudWatch 

Then go to the [deeplens console]() and edit your project function and point it
to the newly created `deeplensFaceDetection` lambda function

Then select the project and deploy it to the device. 

Subscribe to the channel on the [IoT console](https://console.aws.amazon.com/iot/home?region=us-east-1#/test) and look messages `Face pushed to S3` which indicate the images are
being pushed successfully to S3.

Then go to the [cloudwatch console](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#)
and create a new Dashboad, select `Add Widget`, `Line`, `Custom Namespaces` and select
all the metrics.
Make sure to enable `Auto refresh` and you should start seeing the graph of the emotions
detected. 


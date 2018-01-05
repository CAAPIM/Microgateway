# Secured AWS Services Integration with Microgateway -- Sample Use Cases <a name="AWS Sample_Use_Case"></a>

Table of Contents:

* [Get Started](#Get_Started)
* [Prerequisite](#Prerequisite)
* [Use case #1 - Hosting video on S3](#Usecase1)
  * [Description](#Usecase1_description)
       * [Assumption](#Usecase1_assumption)
  * [Step-by-step](#Usecase1_step_by_step)
    * [Publish an API to allow generating an AWS signed Url for uploading content to S3](#case1_publish_api)
    * [Use the "getUploadUrl" API to request for a signed Url](#Usecase1_getUploadUrl)
    * [Use the returned "signedUrl" to upload file to S3 bucket](#Usecase1_upload)

* [Use case #2 - AlertMessenger using Lambda function](#Usecase2)
  * [Description](#Usecase2_description)
       * [Assumption](#Usecase2_assumption)
  * [Step-by-step](#Usecase2_step_by_step)
    * [Publish an API to invoke a Lambda function](#case2_publish_api)
    * [Use the "invokeLambdaFunction" API to invoke the "AlertMessenger" Lambda function](#Usecase2_invoke)
    
 * [Secured AWS Integration with Microgateway - Quickstart](AWS_Integration_Quickstart.md)
  


## Get Started <a name="Get_Started"></a>
This document will describe step-by-step of some sample use cases.  The intention is to show how users can expose and use AWS services through Microgateway.  
As an example, we have implemented all of the sample of the Lambda function and packaged them in the Samples.jar file.
Users can download the "Samples.jar" file and use as described in the sample below.

## Prerequisite <a name="Prerequisite"></a>
All the use cases below will assume that user already have AWS account and its credentials.  

For this example, we will assume the user has the following AWS credentials.  For real use cases, user must replace those assumed credentials with the actual user's AWS credentials.  

Assume:
- user AWS access key: AKIMSC2WSOR3OZI6ZOA
- user AWS secret key: VOWX3e2XdPWotFq5oHdTMgL4hSHsoFog0uiCCqlxy
- all the samples are assume to run in "ca-central-1" region on AWS cloud.  You can change to the region of your preference
- user downloaded the "Sample.jar" from our Validator or github site.

There might be other assumptions for each specific use case describe below.  Those specific assumptions will be mentioned with the specific use case.


## Use case #1 - Hosting video on S3 <a name="Usecase1"></a>
### Description <a name="Usecase1_description"></a>
This use case describes how user can upload a video into an S3 bucket.  As the result, others can publically view the video.
The enterprise "Best Practice" way of uploading a content to an S3 bucket is to request for an AWS signed Url by calling the API expose by our gateway.  Once receiving the signed Url, the client/user can use any appropriated tool to upload a content to an S3 bucket.  In this example, we will be using "curl" command line to upload content.


##### Assumption <a name="Usecase1_assumption"></a>
- User already created or has an existing S3 bucket where a video can be uploaded to.
- User has a sample video to use for upload.  In this example, we will assume the video file name is "movie.mp4".


### Step-by-step <a name="Usecase1_step_by_step"></a>
##### Publish an API to allow generating an AWS signed Url for uploading content to S3<a name="case2_publish_api"></a>

- service template

    ```json
     {
       "Service": {
         "name": "Generating a signed URL",
         "gatewayUri": "/getUploadUrl",
         "httpMethods": [
           "post",
           "get",
           "put",
           "delete"
         ],
         "policy": [
           {
             "AWS": {
               "config": {
                 "service": {
                   "name": "S3",
                   "method": "generatePresignedPutUrl"
                 },
                 "account": {
                   "key": "AKIMSC2WSOR3OZI6ZOA",
                   "secret": "VOWX3e2XdPWotFq5oHdTMgL4hSHsoFog0uiCCqlxy",
                   "region": "ca-central-1"
                 }
               }
             }
           }
         ]
       }
     }   
    ```
- result endpoint: 

      ```
      http://<host>:<port>/getUploadUrl
    ```

##### Use the "getUploadUrl" API to request for a signed Url <a name="Usecase1_getUploadUrl"></a>
 - payload format
    ```json
    {
        "bucketName": "<Enter-your-EXISTING-bucket-name-here>",
        "resourceKey": "<folder/name-of-your-upload-file-here>",
        "contentType": "<content mine type of your file>",
        "expireTimeInMillis": "<expiration-time-for-signed-url-in-milliseconds>",
        "isPublicRead": "<true if you want to allow public access to this content OR false, otherwise>"
    }
    ```
- sample payload
    ```json
    {
        "bucketName": "hosting-bucket",
        "resourceKey": "movies/movie.mp4",
        "contentType": "video/mp4",
        "expireTimeInMillis": "1800000",
        "isPublicRead": "true"
    }
    ```
- command

    ```
    curl -H "Content-Type: application/json" -X GET -d '{ "bucketName": "hosting-bucket", "resourceKey": "movies/movie.mp4", "contentType": "video/mp4", "expireTimeInMillis": "1800000", "isPublicRead": "true"}' http://localhost:8080/getUploadUrl
    ```

- result
    ```json
    {
        "signedUrl": "https://hosting-bucket.s3.ca-central-1.amazonaws.com/movies/movie.mp4?x-amz-acl=public-read&Content-Type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171206T024034Z&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Expires=1800&X-Amz-Credential=AKIMSC2WSOR3OZI6ZOA%2F20171206%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=a83d4740c193966835ec44bfb8d75ca1cf2f74ca1cb16b9d60f27fa733c8c560"
    }
    ```

##### Use the returned "signedUrl" to upload file to S3 bucket  <a name="Usecase1_upload"></a>

- command
    ```
    curl -v -H "Content-Type: video/mp4" --upload-file movie.mp4 "https://hosting-bucket.s3.ca-central-1.amazonaws.com/movies/movie.mp4?x-amz-acl=public-read&Content-Type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171206T024034Z&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Expires=1800&X-Amz-Credential=AKIMSC2WSOR3OZI6ZOA%2F20171206%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=a83d4740c193966835ec44bfb8d75ca1cf2f74ca1cb16b9d60f27fa733c8c560"
    ```
- result<br>
The file "movie.mp4" should now be upload into your bucket "hosting-bucket" under folder "movies"



## Use case #2 - AlertMessenger using Lambda function <a name="Usecase2"></a>
### Description <a name="Usecase2_description"></a>
This use case describes how a company using Lambda function to send out email alert to users/subscribers.

##### Assumption <a name="Usecase2_assumption"></a>
- User already downloaded "Sample.jar" from our Validator or github. 
- User uploaded the "Sample.jar" to user's owned S3 bucket.  User must obtained the URL to the "Sample.jar" on S3 which user used to create a Lambda function "AlertMessenger" below.
- User create Lambda function, "AlertMessenger" as follow:
    - Lambda handler "lambda.sms::CommandHandler" which will send out an Email message to a list of subscribers.
    - Lambda function "Code entry type" is "Upload a file from Amazon S3" with the URL to the "Sample.jar" file on S3
    - Lambda function "Runtime" is "Java 8"
    - Assign "AWSLambdaBasicExecutionRole", "AWSLambdaExecute", "AWSLambdaRole", "AmazonSNSFullAccess" and "AmazonSNSRole" policies to the Lambda function
    

### Step-by-step <a name="Usecase2_step_by_step"></a>
##### Publish an API to invoke a Lambda function <a name="case2_publish_api"></a>

- service template

    ```json
    {
      "Service": {
        "name": "Alert Email Message to Users",
        "gatewayUri": "/invokeLambdaFunction",
        "httpMethods": [
          "get",
          "put",
          "post",
          "delete"
        ],
        "policy": [
          {
            "AWS": {
              "config": {
                "service": {
                  "name": "Lambda",
                  "method": "invokeAsync"
                },
                "account": {
                  "key": "AKIMSC2WSOR3OZI6ZOA",
                  "secret": "VOWX3e2XdPWotFq5oHdTMgL4hSHsoFog0uiCCqlxy",
                  "region": "ca-central-1"
                }
              }
            }
          }
        ]
      }
    }    
    ```
- result endpoint: 

      ```
      http://<host>:<port>/invokeLambdaFunction
      ```

##### Use the "invokeLambdaFunction" API to invoke the "AlertMessenger" Lambda function  <a name="Usecase2_invoke"></a>
 - payload format
 
    ```
    {
        "functionName": "Lambda function you want to invoke",
        "functionPayload": {
           <JSON format data that the Lambda function is expected, if any>
        }
    }      
    ``` 

- sample payload

    ```json
    {
        "functionName": "AlertMessenger",
        "functionPayload": {
            "message": "This is an operational alert message for Public Transit users.  Due to techincal difficulties, the service is temporary down.  We will update when the service is up and running again.",
            "emails": [
                "your.email@ca.com",
                "another.email@gmail.com"
            ]
        }
    }
    ``` 
- command

    ```
    curl -H "Content-Type: application/json" -X GET -d '{"functionName": "AlertMessenger", "functionPayload": {"message": "This is an operational alert message for Public Transit users.  Due to techincal difficulties, the service is temporary down.  We will update when the service is up and running again.", "emails": ["your.email@ca.com", "another.email@gmail.com" ] }}' http://localhost:8080/create_deploy_bucket
    ```

- result<br>
Alert email message is sent to the emails "your.email@ca.com" and "another.email@gmail.com"

### Get further to try more complex scenarios <a name="get-further"></a>

- Orchestrate API with Secured AWS Integration
    - [Echo your message](AWS_Integration_Sample_use_case_1.md)
    - [Replicate your files](AWS_Integration_Sample_use_case_2.md)
- [Documentation](configure-and-consume-AWS-Lambda-and-S3-APIs-with-json-file.md)
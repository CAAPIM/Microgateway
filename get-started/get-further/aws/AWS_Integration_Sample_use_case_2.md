# Orchestrate API with Secured AWS Integration <a name="AWS Sample_Use_Case_2"></a>

Table of Contents:

* [Get Started](#Description)
* [Prerequisite](#Prerequisite)
* [Use case # replicate](#Usercase2)
  * [Step-by-step](#Usecase2_step_by_step)
    * [create an S3 bucket](#create_S3_bucket)
    * [upload file to S3 bucket](#upload_S3_bucket)
    * [create a Lambda function](#create_lambda_function)
    * [invoke a Lambda function](#invoke_lambda_function)


## Get started <a name="Get started"></a>
This document will describe a scenario when you need to replicate objects in multiple S3 buckets..  

## Prerequisite <a name="Prerequisite"></a>
All the use cases below will assume that user already have AWS account and its credentials.  

For this example, we will assume the user has the following AWS credentials.  For real use case, use must replace those assumed credentials with the actual user's AWS credentials.  

Assume:
- user AWS access key: AKIMSC2WSOR3OZI6ZOA
- user AWS secret key: VOWX3e2XdPWotFq5oHdTMgL4hSHsoFog0uiCCqlxy

There might be other assumptions for each specific use case describe below.  Those specific assumptions will be mentioned with the specific use case.

## Use case #2 <a name="Usecase2"></a>
This use case will assume:
- User has implemented an 'replicate' Lambda function which will response/echo the data payload it received to the caller.
- User already package AWS Lambda function into a zip file called ‘replicate.zip'. User can download our sample of implementation of the 'replicate’ function 
  "replicate.zip" from the "Validator" site.

This use case will describe steps on how a user can use the APIs to implement a simple CI/CD to deploy a Lambda function to AWS Lambda service using S3 and Lambda service.  The workflow is as follow:
- user create three buckets :  'deployment-bucket-test' , ‘source-bucket-test’ and ‘destination-bucket-test’ on S3
- user request for signed url to deploy ‘replicate.zip' to 'deployment-bucket'
- user uses curl or any appropriate tool to upload the 'replicate.zip' to 'deployment-bucket'
- user create an 'replicate' Lambda function which has its implementation as part of the 'replicate.zip'
- client/user can invoke the create Lambda function which was created.
- the result, the user will received whatever the data/message user sent to the 'replicate' Lambda function.


### Step-by-step <a name="Usecase1_step_by_step"></a>
##### create an S3 bucket <a name="create_S3_bucket"></a>
- where we can upload the 'replicate.zip' file to.  This step can be ignore if you already have an S3 bucket which can be use to deploy build packages to.
- create an API to create S3 bucket
    ```json
    {
      "Service": {
        "name": "Create a code drop bucket",
        "gatewayUri": "/create_deploy_bucket",
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
                  "method": "createBucket"
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
- invoke the API to create an S3 bucket called "mgw-deployment-bucket"
  - payload format:
      ```json
      {
          "bucketName": "your bucket name here"
      }
      ```

  - command
      ```
      curl -H "Content-Type: application/json" -X GET -d '{"bucketName": "deployment-bucket-test"}' http://localhost:8080/create_deploy_bucket
      ```

##### upload file to S3 bucket <a name="upload_S3_bucket"></a>
- create an API to request for a signed url to upload file 'replicate.zip' to "deployment-bucket-test"
    ```json
    {
      "Service": {
        "name": "Signed URL to upload to S3 bucket",
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
- invoke the 'getUploadUrl' API to request for a signed Url to upload 'replicate.zip' to 'deployment-bucket-test'

  - payload format
      ```json
      {
          "bucketName": "deployment-bucket-test",
          "resourceKey": "replicate.zip",
          "contentType": "application/x-www-form-urlencoded; charset=utf-8",
          "expireTimeInMillis": "600000",
          "isPublicRead": "false"
      }
      ```
   - command
      ```
      •	curl -v -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" --upload-file replicate.zip "<copy and paste the signed url here>"
      ```

- using curl or appropriate tool to update file using the returned signed Url. In this example, we are using curl to upload a file
  - curl command format
  
    ```
    curl -v -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" --upload-file replicate.zip "<copy and paste the signed url here>"
    ```
  - command
    ```
    curl -v -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" --upload-file replicate.zip ""https://deployment-bucket-test.s3.ca-central-1.amazonaws.com/replicate.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171205T212312Z&X-Amz-SignedHeaders=host&X-Amz-Expires=599&X-Amz-Credential=AKIAJ2JNVGNULTU5JLVQ%2F20171205%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=cb262efec366cfe305b162a4de2327c0a0fa519aa5f44e2fa75049eb042c0457
    ```

Note: Repeat create and upload file for bucket-source-test to upload Object to be replicated and for bucket-deployment-test ,create the bucket

##### create a Lambda function <a name="create_lambda_function"></a>
- create an API to create a Lambda function which will use the deploy jar file as the source for the function

    ```json
    {
      "Service": {
        "name": "Create a Lambda function",
        "gatewayUri": "/createFunction",
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
                  "name": "Lambda",
                  "method": "createFunction"
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
- execute 'createFunction' to create a Lambda functionName

  - payload format
    ```
    {
      "handler": "replicate.lambda_handler",
      "s3Key": "replicate.zip",
      "role": "arn:aws:iam::192443709020:role/lambda_exec_role",
      "functionName": "replicate",
      "description": " replicate objects ",
      "s3Bucket": "deployment-bucket-test",
      "timeout": "300",
      "runtime": "python2.7",
      "memorySize": "512"
    }


    ```
    
  - Command
    ```
    curl -H "Content-Type: application/json" -X GET -d '{"handler": "lambda.echo::CommandHandler","s3Key": "echo.jar","role": "arn:aws:iam::192443709020:role/lambda_exec_role","functionName": "echoMyPayload","description": "echo the payload back to caller","s3Bucket": "mgw-deployment-bucket","timeout": "300","runtime": "java8","memorySize": "512"}' http://localhost:8080/createFunction
    ```

##### invoke a Lambda function <a name="invoke_lambda_function"></a>
- create an API to invoke a Lambda function.
    ```json
    {
      "Service": {
        "name": "Invoke a Lambda function",
        "gatewayUri": "/invokeFunction",
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
- execute 'invokeFunction' to invoke a Lambda function

  - payload format
    ```json
    {
      "functionName": "replicate",
      "functionPayload": {
           "source-bucket":"bucket-source-test",
    	"key": "smiley.jpg",
        	"destination-bucket" :"bucket-destination-test"
       }
    }

    ```
  - Command
    ```
   curl -H "Content-Type: application/json" -X GET -d '{"functionName": "replicate","functionPayload": {"source-bucket":"bucket-source-test","key": "smiley.jpg","destination-bucket" :"bucket-destination-test"}' http://localhost:8080/invokeFunction

    ```
 Note: The solution in replicate.zip can be extended to replicate objects in cross-region S3 buckets and also to upload multiple objects
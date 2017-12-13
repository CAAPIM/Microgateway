# Orchestrate API with Secured AWS Integration <a name="AWS Sample_Use_Case_1"></a>

Table of Contents:

* [Get started](#Description)
* [Prerequisite](#Prerequisite)
* [Use Case : 'echo'](#Usercase1)
  * [Step-by-step](#Usecase1_step_by_step)
    * [create an S3 bucket](#create_S3_bucket)
    * [upload file to S3 bucket](#upload_S3_bucket)
    * [create a Lambda function](#create_lambda_function)
    * [invoke a Lambda function](#invoke_lambda_function)

* [Use Case : 'replicate' ](get-started/get-further/aws/AWS_Integration_Sample_use_case_2.md)

## Get started <a name="Description"></a>
This document will describe step-by-step of each of the use case with the intention to show how users can use the supported AWS services and APIs to orchestrate such use case.  

## Prerequisite <a name="Prerequisite"></a>
All the use cases below will assume that user already have AWS account and its credentials.  

For this example, we will assume the user has the following AWS credentials.  For real use case, use must replace those assumed credentials with the actual user's AWS credentials.  

Assume:
- user AWS access key: AKIMSC2WSOR3OZI6ZOA
- user AWS secret key: VOWX3e2XdPWotFq5oHdTMgL4hSHsoFog0uiCCqlxy

There might be other assumptions for each specific use case describe below.  Those specific assumptions will be mentioned with the specific use case.

## Use case : 'echo' <a name="Usecase1"></a>
This use case will assume:
- User has implemented an 'echo' Lambda function which will response/echo the data payload it received to the caller.
- User already package AWS Lambda function into a jar file called 'echo.jar'.   User can download our sample of implementation of the 'echo' function "echo.jar" from the "Validator" site. 

This use case will describe steps on how a user can use the APIs to implement a simple CI/CD to deploy a Lambda function to AWS Lambda service using S3 and Lambda service.  The workflow is as follow:
- user create a 'mgw-deployment-bucket' named bucket on S3
- user request for signed url to deploy 'echo.jar' to S3
- user uses curl or any appropriate tool to upload the 'echo.jar' to 'mgw-deployment-bucket'
- user create an 'echo' Lambda function which has its implementation as part of the 'echo.jar'
- client/user can invoke the create Lambda function which was created.
- the result, the user will received whatever the data/message user sent to the 'echo' Lambda function.

### Step-by-step <a name="Usecase1_step_by_step"></a>
##### create an S3 bucket <a name="create_S3_bucket"></a>
- where we can upload the 'echo.jar' file to.  This step can be ignore if you already have an S3 bucket which can be use to deploy build packages to.
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
      curl -H "Content-Type: application/json" -X GET -d '{"bucketName": "mgw-deployment-bucket"}' http://localhost:8080/create_deploy_bucket
      ```

##### upload file to S3 bucket <a name="upload_S3_bucket"></a>
- create an API to request for a signed url to upload file 'echo.jar' to "mgw-deployment-bucket"
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
- invoke the 'getUploadUrl' API to request for a signed Url to upload 'echo.jar' to 'mgw-deployment-bucket'

  - payload format
      ```json
      {
          "bucketName": "mgw-deployment-bucket",
          "resourceKey": "echo.jar",
          "contentType": "application/x-www-form-urlencoded; charset=utf-8",
          "expireTimeInMillis": "600000",
          "isPublicRead": "false"
      }
      ```
   - command
      ```
      curl -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" -X GET -d '{"bucketName": "mgw-deployment-bucket","resourceKey": "echo.jar","contentType": "application/x-www-form-urlencoded; charset=utf-8","expireTimeInMillis": "600000","isPublicRead": "false"}' http://localhost:8080/getUploadUrl
      ```

- using curl or appropriate tool to update file using the returned signed Url. In this example, we are using curl to upload a file
  - curl command format
  
    ```
    curl -v -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" --upload-file echo.jar "<copy and paste the signed url here>"
    ```
  - command
    ```
    curl -v -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" --upload-file echo.jar "https://mgw-deployment-bucket.s3.ca-central-1.amazonaws.com/echo.jar?Content-Type=application%2Fx-www-form-urlencoded%3B%20charset%3Dutf-8&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171201T004807Z&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Expires=599&X-Amz-Credential=AKIMSC2WSOR3OZI6ZOA%2F20171201%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=58d9f43eec7732f72f6b3f299a86b997ba36c221d610869910c8dd70c241eed1"
    ```

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
      "handler": "lambda.echo::CommandHandler",
      "s3Key": "echo.jar",
      "role": "arn:aws:iam::192443709020:role/lambda_exec_role",
      "functionName": "echoMyPayload",
      "description": "echo the payload back to caller",
      "s3Bucket": "mgw-deployment-bucket",
      "timeout": "300",
      "runtime": "java8",
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
        "gatewayUri": "/invokeAsyncFunction",
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
- execute 'invokeAsyncFunction' to invoke a Lambda function

  - payload format
    ```json
    {
      "functionName": "echo",
      "functionPayload": {
           "my_message": "Can you hear me now !?"
       }
    }
    ```
  - Command
    ```
    curl -H "Content-Type: application/json" -X GET -d '{"functionName": "echo","functionPayload": {"my_message": "Can you hear me now !?"}}' http://localhost:8080/invokeAsyncFunction
    ```

## Configure and Consume AWS Lambda and S3 APIs with JSON File

Table of Contents:
* [Description](#Description)
* [Prerequisites](#Prerequisites)
* [Create a service/api to consume AWS service](#CreateService)
* [Sample AWS Lambda Methods and Payload](#SampleLambda)
  * [Service: Lambda, Method: invokeAsync](#Lambda_invokeAsync)
  * [Service: Lambda, Method: invoke](#Lambda_invoke)
  * [Service: Lambda, Method: createFunction](#Lambda_createFunction)
  * [Service: Lambda, Method: deleteFunction](#Lambda_deleteFunction)
  * [Service: Lambda, Method: listFunctions](#Lambda_listFunctions)
  * [Service: Lambda, Method: getFunction](#Lambda_getFunction)
* [Sample AWS S3 Methods](#S3_methods)
  * [Service: S3, Method: createBucket](#S3_createBucket)
  * [Service: S3, Method: listBuckets](#S3_listBuckets)
  * [Service: S3, Method: createFolder](#S3_createFolder)
  * [Service: S3, Method: deleteFolder](#S3_deleteFolder)
  * [Service: S3, Method: generatePresignedPutUrl](#S3_generatePresignedPutUrl)
  * [Service: S3, Method: generatePresignedGetUrl](#S3_generatePresignedGetUrl)
  * [Service: S3, Method: getBucketVersioningConfiguration](#S3_getBucketVersioningConfiguration)
  * [Service: S3, Method: deleteMultipleObjects](#S3_deleteMultipleObjects)
  * [Service: S3, Method: listObjects](#S3_listObjects)
  * [Service: S3, Method: copyObject](#S3_copyObject)
  * [Service: S3, Method: setObjectAcl](#S3_setObjectAc)
  * [Service: S3, Method: deepDeleteBucket](#S3_deepDeleteBucket)
  * [Service: S3, Method: deleteBucketVersions](#S3_deleteBucketVersions)
  * [Service: S3, Method: deleteEmptyBucket](#S3_deleteEmptyBucket)
  * [Service: S3, Method: deleteObject](#S3_deleteObject)
  * [Service: S3, Method: getBucketAcl](#S3_getBucketAcl)
  * [Service: S3, Method: getObjectAcl](#S3_getObjectAcl)


## Description <a name="Description"></a>
This document describe some of the simple examples on how to create APIs that route to AWS services.  Currently, AWS assertion support integration with Lambda and S3 services.  We will be soon supporting other services such as 'EC2', 'Kinesis', 'DynamoDB', 'SQS', 'SNS' and other AWS services.

## Prerequisites <a name="Prerequisites"></a>
- You have access to AWS
- You have AWS access key and secret key

## Create a service/api to consume AWS service <a name="CreateService"></a>
You can use the following service template to publish an API that uses AWS service

```json
{
  "Service": {
    "name": "Short name of your service",
    "gatewayUri": "/service_end_point",
    "httpMethods": [
      "post"
    ],
    "policy": [
      {
        "AWS": {
          "config": {
            "service": {
              "name": "AWS Service Name Here",
              "method": "AWS methods to call"
            },
            "account": {
              "key": "Your AWS access key",
              "secret": "Your AWS secret key",
              "region": "AWS Region"
            }
          }
        }
      }
    ]
  }
}
```
- Example:
To create an API that can invoke a Lambda function asynchronously.

```json
{
  "Service": {
    "name": "Invoke Lambda function asynchronously",
    "gatewayUri": "/invokeAsync",
    "httpMethods": [
      "post",
      "get",
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
              "key": "Your AWS access key",
              "secret": "Your AWS secret key",
              "region": "AWS Region"
            }
          }
        }
      }
    ]
  }
}
```
NOTE: make sure you use your own 'key', 'secret' and 'region'

- To consume the above API, you can use curl or any other tool as appropriate
```
curl -u username:password -H "Content-Type: application/json" -X GET http://<host>:8080/invokeAsync -d 'JSON body to send'
```
- example:
```
curl -u admin:adminPassword -H "Content-Type: application/json" -X GET http://<host>:8080 -d '{"functionName": "echo","functionPayload": {"message": "Hello there !!!"}}'
```

### Sample AWS Lambda Methods and Payload  <a name="SampleLambda"></a>
The following samples are referring to the service template above.  For each of the sample, replace with the "name" of the service and the "method" of the service to be used.

##### Service: Lambda, Method: invokeAsync  <a name="Lambda_invokeAsync"></a>
- description: invoke a Lambda function (functionName) asynchronously.
- sample API body/payload
```
{
    "functionName": "lambda function you want to invoke here",
    "functionPayload": {
        <JSON payload that your lambda function is expected>
    }
}
```

##### Service: Lambda, Method: invoke  <a name="Lambda_invoke"></a>
- description: invoke a Lambda function (functionName) synchronously.
- sample API body/payload
```
{
    "functionName": "The name of lambda function you want to invoke here",
    "functionPayload": {
        <JSON payload that your lambda function is expected>
    }
}
```


##### Service: Lambda, Method: createFunction  <a name="Lambda_createFunction"></a>
- description: create a Lambda function (functionName).
- sample API body/payload
```
{
    "handler": "package.class::lambdafunctionHandler_here",
    "s3Key": "jar_filename_on_S3.jar",
    "role": "arn:aws:iam::<account>:role/lambda_exec_role",
    "functionName": "given a name to this new lambda",
    "description": "short description for this function",
    "s3Bucket": "S3_bucket_here",
    "timeout": "maximum time in second this function can run",
    "runtime": "java8",
    "memorySize": "memory size in MB"
}
```

##### Service: Lambda, Method: deleteFunction  <a name="Lambda_deleteFunction"></a>
- description: delete a Lambda functionName
- sample API body/payload
```
{
    "functionName": "echo"
}
```

##### Service: Lambda, Method: listFunctions  <a name="Lambda_listFunctions"></a>
- description: list all Lambda functions
- sample API body/payload
```
Payload NOT REQUIRED.
```

##### Service: Lambda, Method: getFunction  <a name="Lambda_getFunction"></a>
- description: get details of a Lambda functionName
- sample API body/payload
```
{
    "functionName": "name of a Lambda function"
}
```



### Sample AWS S3 Methods  <a name="S3_methods"></a>
The following samples are referring to the service template above.  For each of the sample, replace with the "name" of the service and the "method" of the service to be used.


##### Service: S3, Method: createBucket  <a name="S3_createBucket"></a>
- description: create an S3 buckets
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: listBuckets  <a name="S3_listBuckets"></a>
- description: list all S3 buckets
- sample API body/payload
```
payload NOT REQUIRED
```

##### Service: S3, Method: createFolder  <a name="S3_createFolder"></a>
- description: list all S3 buckets
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "folderName": "a-folder-name-here"
}
```

##### Service: S3, Method: deleteFolder  <a name="S3_deleteFolder"></a>
- description: delete a folder under a bucket
- sample API body/payload
```
{
    "bucketName": "mgw-awsassertion",
    "folderName": "test-folder"
}
```

##### Service: S3, Method: generatePresignedPutUrl  <a name="S3_generatePresignedPutUrl"></a>
- description: request a signed URL with S3. The respond is the signed URL.  You can then use curl or other appropriate tool to upload a file to a specific S3 bucket.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "resourceKey": "a-folder-name-here/uploadFile.extension",
    "expireTimeInMillis": "6000000",
    "isPublicRead": "false",
    "contentType": "plain/text"
}
```
NOTE:
	curl command to upload file using signed Url

	curl -v -H "Content-Type: <content type>"  --upload-file <filename> <signed url>

	curl -v -H "Content-Type: plain/text" --upload-file history.txt
    "https://mgw-awsassertion.s3.ca-central-1.amazonaws.com/test-folder/uploadFile.txt?Content-Type=plain%2Ftext&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171109T164534Z&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Expires=6000&X-Amz-Credential=AKIAISPYSVB5HOZI6ZOA%2F20171109%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=1262c13cb8c211ba8bb34a019075bfc05b5b9c97803c29e06439a1f326c20265"

NOTE:
You MUST use -H "Content-Type" header in the curl command above otherwise the upload will failed with "403 Forbidden"

##### Service: S3, Method: generatePresignedGetUrl  <a name="S3_generatePresignedGetUrl"></a>
- description: request a signed URL with S3. The respond is the signed URL.  You can then use curl or other appropriate tool to download a file from a specific S3 bucket.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "resourceKey": "a-folder-name-here/uploadFile.extension",
    "expireTimeInMillis": "555555"
}
```

NOTE:
	curl command to download object from S3 using signed Url
	format:  ```curl -v -X GET "<signed url>" > local_file_name```

    curl -v -X GET "https://mgw-sandbox.s3.ca-central-1.amazonaws.com/uploadFolder/awsLocationCopy.jar?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171108T235520Z&X-Amz-SignedHeaders=host&X-Amz-Expires=555&X-Amz-Credential=AKIAISPYSVB5HOZI6ZOA%2F20171108%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=ab212f36382f408ede89b9c6c6f16f047e83f5dd524d666f9be2c12ae73bb201" > awsLocation.jar


##### Service: S3, Method: getBucketVersioningConfiguration  <a name="S3_getBucketVersioningConfiguration"></a>
- description: get configuration information of a bucket.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: deleteMultipleObjects  <a name="S3_deleteMultipleObjects"></a>
- description: delete multiple S3 files/objects.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "objects": [
        "test-folder/uploadFile.txt",
        "test-folder/uploadFile2.txt"
    ]
}
```

##### Service: S3, Method: listObjects  <a name="S3_listObjects"></a>
- description: list all the files/objects under an S3 bucket.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: copyObject  <a name="S3_copyObject"></a>
- description: copy a file from a bucket to another file.
- sample API body/payload
```
{
    "fromBucket": "from-bucket-name-here",
    "fromObject": "uploadFolder/awsLocationCopy.jar",
    "toObject": "test-folder/awsLocationNewCopy.jar",
    "toBucket": "to-bucket-name-here"
}
```

##### Service: S3, Method: setObjectAcl  <a name="S3_setObjectAcl"></a>
- description: set access control for S3 file/object.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "granteeId": "3456f16bf4e105839c092836e84df884355c16ee0257e74a8d6d2af0a6b7924d",
    "objectKey": "test-folder/awsLocationNewCopy.jar",
    "permission": "Write",
    "granteeType": "canonical"
}
```

##### Service: S3, Method: deepDeleteBucket  <a name="S3_deepDeleteBucket"></a>
- description: deleting all files/objects within the bucket before deleting the bucket itself.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: deleteBucketVersions  <a name="S3_deleteBucketVersion"></a>
- description: deleting all S3 bucket version.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: deleteEmptyBucket  <a name="S3_deleteEmptyBucket"></a>
- description: deleting an empty S3 bucket.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: deleteObject  <a name="S3_deleteObject"></a>
- description: deleting an S3 file/object.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "objectName": "folder-if-any/fileToBeDeleted.txt"
}
```

##### Service: S3, Method: getBucketAcl  <a name="S3_getBucketAcl"></a>
- description: get access control list of a bucket.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here"
}
```

##### Service: S3, Method: getObjectAcl  <a name="S3_getObjectAcl"></a>
- description: get access control list of a file/object.
- sample API body/payload
```
{
    "bucketName": "a-bucket-name-here",
    "objectKey": "folder-if-any/a-file.txt"
}
```

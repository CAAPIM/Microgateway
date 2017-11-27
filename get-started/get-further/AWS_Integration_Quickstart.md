# Secured AWS Services Integration with Microgateway -- Quick-start Documentation <a name="AWS Integration"></a>

Table of Contents:

* [Description](#Description)
* [Sample Service Template using AWS services](#SampleServiceTemplate)
* [How to Call Service Endpoints](#CallServiceEndpoints)
* [Supporting Services and Methods](#SupportServiceMethods)



## Description <a name="Description"></a>
AWS assertion provides a way to integrate the Microgateway with AWS Services.  It routes APIs calls to AWS services  

## Sample Service Template using AWS services <a name="SampleServiceTemplate"></a>
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
Where:
  - <b>'AWS Service Name Here'</b> is one of 'Lambda' or 'S3'.  In the near future we will be supporting other service such as 'EC2', 'Kinesis', 'DynamoDB', 'SQS', 'SNS' and other AWS services.

  - <b>'AWS method to call'</b> is one of the AWS methods from the selected AWS service above. The list of supported AWS methods depending which AWS service you selected is listed under <I>Supporting Services and Methods</I>


## How to Call Service Endpoints <a name="CallServiceEndpoints"></a>
Different AWS service and different method that you selected required different parameters.  To make calls to endpoints easier, all the method parameters are pass-in as part of the <b>body</b> (ie. payload) of your api call to the endpoints.  The payload is pass-in as a JSON format.  For example, if you were going to call an API using curl command.  The body would be pass-in as the '-D' option of the command.

curl -H "Content-Type: application/json" -X POST -d '{"parameter_name_1":"its_value","parameter_name_2":"its_value"}' http://localhost:8080/service_end_point

The details of each method's payload will be describe in details under <b>Supporting Services and Methods</b>


## Supporting Services and Methods <a name="SupportServiceMethods"></a>
Currently, we are supporting integration to AWS Lambda and S3 services. We will be soon releasing support integration to AWS EC2, Kinesis, DynamoDB, SQS, SNS and other AWS services. The following is a list of current supported services, their methods and sample of the payload.

### Services:  Lambda  <a name="Lambda"></a>
Depending on the method, some of the methods might not require any payload.  In that case, you do not need to send any payload with the request.  However, if the payload is required, the payload is a json payload and might contain of the following:

```json
{
  "functionName": "either a name or an ARN of lambda function to call",
  "functionPayload": {
	   <any JSON payload to pass into the Lambda function here...>
	}
}
```
where <br> <b>functionName</b> is REQUIRED name of the Lambda function to call and <br>
<b>functionPayload</b> NOT ALWAYS REQUIRED. If your Lambda function is expected a payload then the payload is sent as the body of the <b>functionPayload</b>.  If the payload is NOT REQUIRED then the <b>functionPayload</b> can be an empty json '{}' or just "".

##### Example of Accepted payload <a name="Expected_payload_Example"></a>
Assuming you have created a Lambda function 'echo' which will reply with whatever the content of the functionPayload. And you have create an endpoint, '/can_you_hear_me' the sample payload and calling the endpoint would be as follow:

```json
{
  "functionName": "echo",
  "functionPayload": {
	"message": "Hello there !!!"
	}
}
```
To call the endpoints:<br>
<i>
curl -H "Content-Type: application/json" -X POST -d '{"functionName": "echo","functionPayload": {"message": "Hello world !!!"}}' http://localhost:8080/can_you_hear_me
</i>

Expected response would be:
```json
{"message":"Hello world !!!"}
```

#### Methods: invokeAsync <a name="invokeAsync"></a>
invoke a lambda function which you specify in the <b>functionName</b> below, asynchronously.

##### Accepted payload <a name="Lambda_invokeAsync_payload"></a>

```json
{
    "functionName": "name of lambda function",
    "functionPayload": "a json payload to send when invoking the function"
}
```
##### Expected response <a name="Lambda_invokeAsync_response"></a>
```json
{
    "statusCode": "return status from lambda invoke",
    "payload": "ris a json format string. The content of the response depending on the implementation of a specific function....",
    "error": "error message if any",
    "logResult": "lambda invoke log result"
}
```

#### Methods: invoke <a name="invoke"></a>
invoke a lambda function, which you specify in the <b>functionName</b> below, synchronously.

##### Accepted payload <a name="Lambda_invoke_payload"></a>
```json
{
    "functionName": "name of lambda function",
    "functionPayload": "a json payload to send when invoking the function"
}
```
##### Expected response <a name="Lambda_invoke_response"></a>
```json
{
    "statusCode": "return status from lambda invoke",
    "payload": "response payload",
    "error": "error message if any",
    "logResult": "lambda invoke log result"
}
```


#### Methods: listFunctions <a name="listFunctions"></a>
get all Lambda functions and their details.

##### Accepted payload <a name="Lambda_listFunctions_payload"></a>
```json
*** NOT REQUIRED.  ***
```

```json
{
    "listFunctions" : [
        {
            "functionName": "name of the lambda function",
            "codeSize": "the size of lambda function in Bytes",
            "description": "description of the function.",
            "functionArn": "Amazon Resource Name of the function",
            "handler": "function handler",
            "lastModified": "last modified of the function",
            "memorySize": "memory size of the function",
            "role": "role to use when running this function",
            "runtime": "runtime environment for this function",
            "timeout" : "the timetout for this function",
            "version" : "the version for this function"
        },
        {
            ....
        }
    ]
}
```

#### Methods: getFunction <a name="getFunction"></a>
get information about a lambda function

##### Accepted payload <a name="Lambda_getFunction_payload"></a>
```json
{
    "functionName": "name of the lambda function",
}
```

##### Expected response <a name="Lambda_getFunction_response"></a>
```json
{
    "functionName": "name of the lambda function",
    "codeSize": "the size of lambda function in Bytes",
    "description": "description of the function.",
    "functionArn": "Amazon Resource Name of the function",
    "handler": "function handler",
    "lastModified": "last modified of the function",
    "memorySize": "memory size of the function",
    "role": "role to use when running this function",
    "runtime": "runtime environment for this function",
    "timeout" : "the timetout for this function",
    "version" : "the version for this function"
}
```

##### Methods: createFunction <a name="createFunction"></a>
create a lambda function

###### Accepted payload <a name="Lambda_createFunction_payload"></a>
```json
{
    "functionName": "name of the lambda function",
    "handler": "lambda function handler",
    "s3Bucket": "s3 bucket where the code is located",
    "s3Key": "the code .jar file with its s3 path",
    "role": "role to use when running lambda function",
    "timeout": "the timeout for the function. Lambda function has a hard limit of 5 minutes",
    "description": "function description"
}
```

##### Expected response <a name="Lambda_getFunction_response"></a>
```json
{
    "functionName": "name of the lambda function",
    "functionArn": "ARN of lambda function you just created"
}        
```

#### Methods: deleteFunction <a name="deleteFunction"></a>
 delete a lambda function

##### Accepted payload <a name="Lambda_deleteFunction_payload"></a>
 ```json
 {
     "functionName": "name of the lambda function to be deleted"
 }
 ```

##### Expected response <a name="Lambda_deleteFunction_response"></a>
```json
 {
     "functionName": "name of the deleted lambda function",
     "deleteResult": "additional deleted result, if any"
  }
```

### Services:  S3  <a name="S3"></a>
Supporting various S3 related methods which will allow user to 'createBucket', 'listBucket', 'deepDeleteBucket', 'deleteEmptyBucket', 'deleteBucketVersions', 'setBucketAcl', 'getBucketAcl', 'listObjects', 'copyObject', 'deleteObject', 'deleteMultipleObjects', 'createFolder', 'deleteFolder', 'generatePresignedPutUrl', 'generatePresignedGetUrl', 'setObjectAcl', 'getObjectAcl' and 'getBucketVersioningConfiguration'


#### Methods: createBucket <a name="createBucket"></a>
create an S3 bucket

##### Accepted payload <a name="S3_createBucket_payload"></a>
 ```json
 {
     "bucketName": "name of a bucket to be created",
 }
 ```

##### Expected response <a name="S3_createBucket_response"></a>
```json
{
    "bucketName": "your bucket name here",
    "owner": "bucker owner",
    "createDate": "date of bucket creation."
}
```

#### Methods: listBucket <a name="listBucket"></a>
list all buckets under your account

##### Accepted payload <a name="S3_listBucket_payload"></a>
 ```json
 ** not require **
 ```

##### Expected response <a name="S3_listBucket_response"></a>
```json
{
    "bucketList":[
        "bucket 1",
        "bucket 2",
        "bucket 3",
        "bucket 4",
        "..."
    ]
}
```

#### Methods: deepDeleteBucket <a name="deepDeleteBucket"></a>
delete bucket and its objects within the bucket.

##### Accepted payload <a name="S3_deepDeleteBucket_payload"></a>
 ```json
 {
     "bucketName": "the name of the bucket to be deleted",
 }
 ```

##### Expected response <a name="S3_deepDeleteBucket_response"></a>
The list of the details of the objects have been deleted.

```json
{
    "bucketName": "deleted bucket name",
    "objects": [
        {
            "key": "object1 key name",
            "etag": "object1 etag",
            "lastModified": "object1 last modified",
            "owner": "object1 owner",
            "size": "object1 size",
            "storageClass": "object1 storage class"
        },
       {
            "key": "object2 key name",
            "etag": "object2 etag",
            "lastModified": "object2 last modified",
            "owner": "object2 owner",
            "size": "object2 size",
            "storageClass": "object2 storage class"},
        }
   ]
}
```

#### Methods: deleteEmptyBucket <a name="deleteEmptyBucket"></a>
delete an empty bucket.

##### Accepted payload <a name="S3_deleteEmptyBucket_payload"></a>
 ```json
 {
     "bucketName": "your bucket name here",
 }
 ```

##### Expected response <a name="S3_deleteEmptyBucket_response"></a>
```json
{
    "bucketName": "bucket name here",
    "location": "the locatoin of the bucket"
}
```

#### Methods: deleteBucketVersions <a name="deleteBucketVersions"></a>
delete all of the bucket versions.

##### Accepted payload <a name="S3_deleteBucketVersions_payload"></a>
 ```json
 {
     "bucketName": "your bucket name here",
 }
 ```

##### Expected response <a name="S3_deleteBucketVersions_response"></a>
```json
{
    "bucketName": "bucket name",
    "versions": [
        {
            "key": "object1 key name",
            "versionId": "object1 versionId"
         },
       {
            "key": "object1 key name",
            "versionId": "object1 versionId"
        }
   ]
}
```

#### Methods: setBucketACL <a name="setBucketACL"></a>
Setting Access Control List (Acl) for a bucket

##### Accepted payload <a name="S3_setBucketACL_payload"></a>
 ```json
 {
     "bucketName": "your bucket name here",
     "granteeType": "one of email|canonical",
     "granteeId": "id of the grantee based on the type you choose above",
     "permission": "one of these: AuthenticatedRead|AwsExecRead|BucketOwnerFullControl|LogDeliveryWrite|private|PublicRead|PublicReadWrite"
 }
 ```

##### Expected response <a name="S3_setBucketACL_response"></a>
```json
{
    "bucketName": "bucket name here",
    "grants": [
        {
            "grantId": "bucket grant1 identifier",
            "grantType": "bucket grant1 type",
            "permission": "bucket grant1 permission,
         },
       {
            "grantId": "bucket grant2 identifier",
            "grantType": "bucket grant2 type",
            "permission": "bucket grant2 permission,
        }
   ]
}
```

#### Methods: getBucketACL <a name="getBucketACL"></a>
Getting Access Control List (Acl) for a bucket

##### Accepted payload <a name="S3_getBucketACL_payload"></a>
 ```json
 {
     "bucketName": "your bucket name here"
 }
 ```

##### Expected response <a name="S3_getBucketACL_response"></a>
```json
{
    "bucketName": "bucket name here",
    "grants": [
        {
            "grantId": "bucket grant1 identifier",
            "grantType": "bucket grant1 type",
            "permission": "bucket grant1 permission,
         },
       {
            "grantId": "bucket grant2 identifier",
            "grantType": "bucket grant2 type",
            "permission": "bucket grant2 permission,
        }
   ]
}
```

#### Methods: copyObject <a name="copyObject"></a>
copy an object from a fromBucket to a toObject under toBucket

##### Accepted payload <a name="S3_copyObject_payload"></a>
 ```json
 {
     "fromBucket": "your source bucket name here",
     "fromObject": "your source object name here",
     "toBucket": "your destination bucket name here",
     "toObject": "your destination object name here"
 }
```

##### Expected response <a name="S3_copyObject_response"></a>
```json
{
    "bucketName": "bucket name here",
    "objectName": [
        {"expirationTime": "expiration time of the new object},
        {"modifiedDate": "modification date of the new object"},
        {"eTag": "eTag of the new object"}
    ]
}
```
#### Methods: deleteObject <a name="deleteObject"></a>
copy an object from a fromBucket to a toObject under toBucket

##### Accepted payload <a name="S3_deleteObject_payload"></a>
 ```json
 {
     "fromBucket": "your source bucket name here",
     "fromObject": "your source object name here",
     "toBucket": "your destination bucket name here",
     "toObject": "your destination object name here"
 }
```

##### Expected response <a name="S3_deleteObject_response"></a>
```json
{
    "bucketName": "bucket name here",
    "objectName": [
        {"expirationTime": "expiration time of the new object},
        {"modifiedDate": "modification date of the new object"},
        {"eTag": "eTag of the new object"}
    ]
}
```

#### Methods: deleteMultipleObjects <a name="deleteMultipleObjects"></a>
deleting more than one objects from the same bucket.

##### Accepted payload <a name="S3_deleteMultipleObjects_payload"></a>
 ```json
 {
    "bucketName": "your bucket name here",
    "objects":[
        "path/to/objectName1",
        "path/to/objectName2",
        "path/to/objectName3",
        "..."
    ]
}
```

##### Expected response <a name="S3_deleteMultipleObjects_response"></a>
```json
{
    "bucketName": "your bucket name here",
    "deletedObjects":[
        "path/to/objectName1",
        "path/to/objectName2",
        "path/to/objectName3",
        "..."
    ]
}
```

#### Methods: createFolder <a name="createFolder"></a>
create a folder under a bucket.

##### Accepted payload <a name="S3_createFolder_payload"></a>
 ```json
 {
    "bucketName": "your bucket name here",
    "folderName": "name of the folder to be created"
}
```

##### Expected response <a name="S3_createFolder_response"></a>
```json
{
    "bucketName": "your bucket name here",
    "folderName": "name of the folder to be created"
}
```

#### Methods: deleteFolder <a name="deleteFolder"></a>
This method first deletes all the files in given folder and than deleting the folder itself

##### Accepted payload <a name="S3_deleteFolder_payload"></a>
 ```json
 {
    "bucketName": "your bucket name here",
    "folderName": "name of the folder to be created"
}
```

##### Expected response <a name="S3_deleteFolder_response"></a>
```json
{
    "bucketName": "your bucket name here",
    "keys": [
        "delete key 1",
        "delete key 2",
        "..."
    ]
}
```

#### Methods: deleteFolder <a name="deleteFolder"></a>
This method first deletes all the files in given folder and than deleting the folder itself

##### Accepted payload <a name="S3_deleteFolder_payload"></a>
 ```json
 {
    "bucketName": "your bucket name here",
    "folderName": "name of the folder to be created"
}
```

##### Expected response <a name="S3_deleteFolder_response"></a>
```json
{
    "bucketName": "your bucket name here",
    "keys": [
        "delete key 1",
        "delete key 2",
        "..."
    ]
}
```

#### Methods: generatePresignedPutUrl <a name="generatePresignedPutUrl"></a>
request for a pre-signed URL to use in PUT operation.  The gateway will return a signed Url to allow user to securely uploading content to a specific bucket. The user can then either use curl or other tools to upload content directly to S3 bucket using the returned URL.  Please, look at the example below to learn how to upload a file using the return URL.

##### Accepted payload <a name="S3_generatePresignedPutUrl_payload"></a>
 ```json
 {
     "bucketName": "your bucket name here",
     "resourceKey": "S3 file resource to be created by the PUT operation",
     "contentType": "content type of the file to be created",
     "expireTimeInMillis": "the expiration time in millisecs for the pre-signed URL",
     "isPublicRead": "setting true|false whether the resource is a public read or not"
 }
```
where 'resourceKey' is the 'folder/filename' of the destination filename.

##### Expected response <a name="S3_generatePresignedPutUrl_response"></a>
```json
{
    "signedUrl": "the signed url"
}
```
Assume the returned URL was:
https://mgw-awsassertion.s3.ca-central-1.amazonaws.com/test-folder/uploadFile.txt?Content-Type=plain%2Ftext&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171109T164534Z&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Expires=6000&X-Amz-Credential=ARMAISPYSVB5HOZI6ZOA%2F20171109%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=1262c13cb8c211ba8bb34a019075bfc05b5b9c97803c29e06439a1f326c20265

	curl command to upload file using signed Url

	format:
	curl -v -H "Content-Type: <content type>"  --upload-file <filename> <signed url>

	curl -v -H "Content-Type: plain/text" --upload-file history.txt  "https://mgw-awsassertion.s3.ca-central-1.amazonaws.com/test-folder/uploadFile.txt?Content-Type=plain%2Ftext&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171109T164534Z&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Expires=6000&X-Amz-Credential=ARMAISPYSVB5HOZI6ZOA%2F20171109%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=1262c13cb8c211ba8bb34a019075bfc05b5b9c97803c29e06439a1f326c20265"

	NOTE:
	You MUST use -H "Content-Type" header in the curl command above otherwise the upload will failed with "403 Forbidden"


#### Methods: generatePresignedGetUrl <a name="generatePresignedGetUrl"></a>
  request for a pre-signed URL to use in GET operation.  The gateway will return a signed Url to allow user to securely downloading content from a specific bucket. The user can then either use curl or other tools to download content directly from S3 bucket using the returned URL.  Please, look at the example below to learn how to download a file using the return URL.

##### Accepted payload <a name="S3_generatePresignedGetUrl_payload"></a>
 ```json
{
    "bucketName": "your bucket name ",
    "resourceKey": "S3 file resource to be created by the GET operation",
    "expireTimeInMillis": "the expiration time in millisecs for the pre-signed URL"
}
```
where 'resourceKey' is the 'folder/filename' of the destination filename.

##### Expected response <a name="S3_generatePresignedPutUrl_response"></a>
```json
{
    "signedUrl": "the signed url"
}
```
NOTE:
	curl command to download object from S3 using signed Url
	format:  curl -v -X GET "<signed url>" > local_file_name

curl -v -X GET "https://mgw-sandbox.s3.ca-central-1.amazonaws.com/uploadFolder/awsLocationCopy.jar?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171108T235520Z&X-Amz-SignedHeaders=host&X-Amz-Expires=555&X-Amz-Credential=GSEUDNRTSB5HOZI6ZOA%2F20171108%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=ab212f36382f408ede89b9c6c6f16f047e83f5dd524d666f9be2c12ae73bb201" > myDownloadedJarFile.jar


#### Methods: setObjectACL <a name="setObjectACL"></a>
Setting object ACL.

##### Accepted payload <a name="S3_setObjectACL_payload"></a>
 ```json
 {
     "bucketName": "your bucket name here",
     "objectKey": "S3 file resource to be set with ACL permission",
     "granteeType": "the type of grantee",
     "granteeId" : "id of the grantee",
     "permission": "permission to set to bucketName/objectKey file"
 }
```
where 'objectKey' is the 'folder/filename' of the destination filename.

##### Expected response <a name="S3_setObjectACL_response"></a>
```json
{
    "bucketName": "name of the bucket",
    "objectKey": "name of the s3 key",
    "grant": [
        {
            "grantId": "grant id",
            "grantType": "grant type",
            "permission": "permission"
        },
        {
            "..."
        }
    ]
}
```

#### Methods: getObjectACL <a name="getObjectACL"></a>
Getting object ACL

##### Accepted payload <a name="S3_getObjectACL_payload"></a>
```json
 {
      "bucketName": "your bucket name here",
      "objectKey": "S3 file resource to be set with ACL permission"
  }
```
where 'objectKey' is the 'folder/filename' of the destination filename.

##### Expected response <a name="S3_getObjectACL_response"></a>
```json
{
     "bucketName": "name of the bucket",
     "objectKey": "name of the s3 key",
     "grant": [
         {
             "grantId": "grant id",
             "grantType": "grant type",
             "permission": "permission"
         },
         {
             "..."
         }
     ]
 }
```

#### Methods: getBucketVersioningConfiguration <a name="getBucketVersioningConfiguration"></a>
Returns the versioning configuration for the specified bucket

##### Accepted payload <a name="S3_getBucketVersioningConfiguration_payload"></a>
```json
{
     "bucketName": "your bucket name here"
}
```
where 'objectKey' is the 'folder/filename' of the destination filename.

##### Expected response <a name="S3_getBucketVersioningConfiguration_response"></a>
```json
{
     "bucketName": "name of the bucket",
     "state": "A bucket's versioning configuration can be in one of three possible states: OFF|ENABLED|SUSPENDED",
     "isMfaDeleteEnabled": "ue if Multi-Factor Authentication (MFA) Delete is enabled for this bucket versioning configuration, false if it isn't enabled, and null if no information is available about the status of MFADelete."
}
```

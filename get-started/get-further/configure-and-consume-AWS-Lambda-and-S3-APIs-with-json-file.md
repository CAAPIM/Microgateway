## Configure and Consume AWS Lambda and S3 APIs with JSON File

**_Prerequisites:_**
- You have access to AWS
- You have already created a AWS Lambda function in AWS Console:
    - You can either create a deployment package of AWS Lambda function and uploaded it to AWS S3
    - or you can create a Lambda function from AWS Lambda console with a sample pre-loaded function


### General Steps To Test Each Method

For each sample method in next section, you will follow the following configuration steps:
1. In Policy Manager, at the bottom left, right click the host name and click ```Publish Web API```
2. Set ```Service Name``` and ```Gateway URL``` fields your arbitrary name (e.g. "aws") and click ```Finish``` button. Leave ```Target URL``` blank.
3. At the top left search box under ```Assertions```, type and click ```AWS```, then drag and drop it to the right pane under the service you created in the step 2
4. AWS properties window will show up: 
    1. Click ```AWS Account Configuration``` tab and set your AWS access key, AWS secret access key, profile, and region
    2. Click ```AWS Service Configuration``` tab and here is where you want to set ```Service Name```, ```Function Name```, and text field below it as you go through the example method below:

### Sample AWS Lambda Methods
- Click ```Service Name``` dropdown and pick ```Lambda```
- Click ```Function Name``` dropdown and pick each function name below
- For each function, paste the following payloads

1. Function Name: ```invokeAsync```
    ```
    {
        "functionName": "echo",
        "functionPayload": {
            "message": "Hello there !!!"
        }
    }
    ```

2. Function Name: ```createFunction```
    ```
    {
        "handler": "lambda.echo::CommandHandler",
        "s3Key": "awsEcho.jar",
        "role": "arn:aws:iam::192443709020:role/lambda_exec_role",
        "functionName": "echo",
        "description": "echo the payload back to caller",
        "s3Bucket": "mgw-sandbox",
        "timeout": "300",
        "runtime": "java8",
        "memorySize": "512"
    }
    ```

3. Function Name: ```deleteFunction```
    ```
    {
        "functionName": "echo"
    }
    ```

4. Function Name: ```listFunctions```
Payload NOT REQUIRED.

5. Function Name: ```getFunction```
    ```
    {
        "functionName": "lambda function name"
    }
    ```

6. Function Name: ```invoke```
    ```
    {
        "functionName": "echo",
        "functionPayload": {
            "my_message": "Can you hear me now !?"
        }
    }
    ```

7. Function Name:  ```invokeAsync```
    ```
    {
        "functionName": "echo",
            "functionPayload": {
                "my_message": "Can you hear me now !?"
            }
    }
    ```

### Sample AWS S3 Methods
1. Function Name:  ```createBucket```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

2. Function Name:  ```listBuckets```
payload NOT REQUIRED

3. Function Name:  ```createFolder```
```
    {
        "bucketName": "mgw-awsassertion",
        "folderName": "test-folder"
    }
```

4. Function Name: ```deleteFolder```
```
    {
        "bucketName": "mgw-awsassertion",
        "folderName": "test-folder"
    }
```

5. Function Name: ```generatePresignedPutUrl```
```
    {
        "bucketName": "mgw-awsassertion",
        "resourceKey": "test-folder/uploadFile.txt",
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

6. Function Name: ```generatePresignedGetUrl```
```
    {
        "bucketName": "mgw-sandbox",
        "resourceKey": "uploadFolder/awsLocationCopy.jar",
        "expireTimeInMillis": "555555"
    }
```

NOTE:
	curl command to download object from S3 using signed Url
	format:  ```curl -v -X GET "<signed url>" > local_file_name```

    curl -v -X GET "https://mgw-sandbox.s3.ca-central-1.amazonaws.com/uploadFolder/awsLocationCopy.jar?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20171108T235520Z&X-Amz-SignedHeaders=host&X-Amz-Expires=555&X-Amz-Credential=AKIAISPYSVB5HOZI6ZOA%2F20171108%2Fca-central-1%2Fs3%2Faws4_request&X-Amz-Signature=ab212f36382f408ede89b9c6c6f16f047e83f5dd524d666f9be2c12ae73bb201" > awsLocation.jar


7. Function Name: ```getBucketVersioningConfiguration```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

8. Function Name: ```deleteMultipleObjects```
```
    {
        "bucketName": "mgw-awsassertion",
        "objects": [
            "test-folder/uploadFile.txt",
            "test-folder/uploadFile2.txt"
        ]
    }
```

9. Function Name: ```listObjects```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

10. Function Name: ```copyObject```
```
    {
        "fromBucket": "mgw-sandbox",
        "fromObject": "uploadFolder/awsLocationCopy.jar",
        "toObject": "test-folder/awsLocationNewCopy.jar",
        "toBucket": "mgw-awsassertion"
    }
```

11. Function Name: ```setObjectAcl```
```
    {
        "bucketName": "mgw-awsassertion",
        "granteeId": "3456f16bf4e105839c092836e84df884355c16ee0257e74a8d6d2af0a6b7924d",
        "objectKey": "test-folder/awsLocationNewCopy.jar",
        "permission": "Write",
        "granteeType": "canonical"
    }
```

12. Function Name:  ```deepDeleteBucket```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

13. Function Name:  ```deleteBucketVersion```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

14. Function Name: ```deleteEmptyBucket```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

15. Function Name: ```deleteObject```
```
    {
        "bucketName": "mgw-awsassertion",
        "objectName": "test-folder/uploadFile.txt"
    }
```

16. Function Name: ```getBucketAcl```
```
    {
        "bucketName": "mgw-awsassertion"
    }
```

17. Function Name: ```getObjectAcl```
```
    {
        "bucketName": "mgw-awsassertion",
        "objectKey": "test-folder"
    }
```
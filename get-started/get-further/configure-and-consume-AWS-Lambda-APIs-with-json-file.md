## Configure and Consume AWS Lambda APIs with JSON File

Prerequisites:
- You have created a deployment package of AWS Lambda function and uploaded it to AWS S3(http://docs.aws.amazon.com/lambda/latest/dg/deployment-package-v2.html)
or
- You have already created a AWS Lambda function in AWS Console

-**_For illustration purpose_**
We will use a sample Java deployment package of AWS Lambda (http://docs.aws.amazon.com/lambda/latest/dg/java-handler-io-type-pojo.html) in this guide. 


- (prerequisite) 1. Create a AWS Lambda function deployment package:

  By following an official AWS Lambda documentation, you will create a deployment package which is required before created a AWS Lambda function:(http://docs.aws.amazon.com/lambda/latest/dg/create-deployment-pkg-zip-java.html).

- (prerequisite) 2. Create a AWS Lambda function:

    Given that we have created a helloworld.zip deployment package from the step 1 above, we will upload the package to AWS following another official AWS documentation page (http://docs.aws.amazon.com/lambda/latest/dg/with-userapp-walkthrough-custom-events-upload.html).

    An example command:
    ```
    aws lambda create-function \
    --region us-east-1 \
    --function-name example \
    --zip-file fileb://PATH_TO/project-dir.zip \
    --role ROLE_ARN_FROM_AWS_IAM \
    --handler example.HelloPojo::handleRequest \
    --runtime java8 \
    --profile default \
    --timeout 10 \
    --memory-size 1024
    ```

    or you can use createFunction to create a Lambda function given that a deployment package is already uploaded to AWS S3

    ```
    {
        "handler": "example.HelloPojo::handleRequest",
        "s3Key": "project-dir.zip",
        "role": "ROLE_ARN_FROM_AWS_IAM",
        "functionName": "example",
        "description": "hello world example",
        "s3Bucket": "S3_BACKET_NAME",
        "timeout": "10"
    }
    ```

- 3. Verify the Lambda function is created:

    ```
    getFunction encass goes here
    ```

    or you can get a list of all the lambda function:
    
    ```
    listFunction encass goes here
    ```

- 4. Test the Lambda function by invoking:

    ```
    invoke encass goes here with the following input: {"firstName": "John","lastName": "Doe"}
    ```

    or you can invoke asynchronously:

    ```
    invokeAsync encass goes here with the following input: {"firstName": "John","lastName": "Doe"}
    ```

- 5. Delete the Lambda function:
    
    ```
    deleteFunction encass goes here
    ```

    ```
    listFunction encass to validate the function deleted
    ```
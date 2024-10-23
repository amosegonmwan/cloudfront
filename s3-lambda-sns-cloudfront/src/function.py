import boto3
import os
import json

s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    s3_bucket = os.environ['WebS3Bucket']
    sns_topic_arn = os.environ['TopicArn']
    region = os.environ['Region']

    for record in event['Records']:
        print(event)
        s3_name = record['s3']['object']['key']

        notification_message = f"New file uploaded to s3 bucket '{s3_bucket}' in '{region}' with key '{s3_name}'"

        sns_response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=notification_message,
            Subject="File Upload Notification"
        )
    return {
        'statusCode': 200,
        'body': json.dumps('processing complete')
    }
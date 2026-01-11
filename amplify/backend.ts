import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { storage } from './storage/resource';
import { Policy, PolicyStatement, Effect } from 'aws-cdk-lib/aws-iam';

/**
 * @see https://docs.amplify.aws/react/build-a-backend/ to add storage, functions, and more
 */
const backend = defineBackend({
  auth,
  data,
  storage,
});

// Create custom IAM policy for S3 access
const storagePolicy = new Policy(backend.stack, 'StorageAuthPolicy', {
  statements: [
    new PolicyStatement({
      effect: Effect.ALLOW,
      actions: [
        's3:GetObject',
        's3:PutObject',
        's3:DeleteObject',
      ],
      resources: [
        `${backend.storage.resources.bucket.bucketArn}/entries/\${cognito-identity.amazonaws.com:sub}/*`,
      ],
    }),
    new PolicyStatement({
      effect: Effect.ALLOW,
      actions: ['s3:ListBucket'],
      resources: [
        backend.storage.resources.bucket.bucketArn,
      ],
      conditions: {
        StringLike: {
          's3:prefix': ['entries/${cognito-identity.amazonaws.com:sub}/*'],
        },
      },
    }),
  ],
});

// Attach policy to authenticated user role
backend.auth.resources.authenticatedUserIamRole.attachInlinePolicy(storagePolicy);

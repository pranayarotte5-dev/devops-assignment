# Task 1 — Multi-Instance EC2 Provisioning

## Implementation Approach


## Why "for_each"?

Using `for_each` avoids code duplication and makes the configuration easier to maintain. Each instance is configured through the input map, allowing instance properties to be changed without duplicating the resource definition.

## Why is "app1" configured separately?

The `app1` instance is defined separately from the other four instances so that it can have a dedicated lifecycle rule. The remaining instances are provisioned using `for_each`.

## Why use "prevent_destroy"?

The `lifecycle` block for `app1` includes:

```hcl
lifecycle {
  prevent_destroy = true
}
```

This setting prevents Terraform from performing a planned destruction of `app1` while the resource configuration containing this lifecycle rule remains in place. If a change would require destroying the instance, Terraform returns an error instead of proceeding.

## Outputs

The configuration exports:

- `instance_ids`: A map of instance names to EC2 instance IDs.
- `private_ips`: A map of instance names to EC2 private IP addresses.

These outputs make it easier to identify and reference the provisioned instances.



# Task 2 — Remote State and Locking

iIf both engineers run `terraform apply`, they may attempt conflicting changes or create duplicate resources The S3 backend gives authorised engineers a shared state location. DynamoDB locking coordinates state-changing operations against that state.



#Task4 

ecr:* across all repositories.
ecs:* across all clusters and services.
S3 upload, overwrite, and delete permissions.
Broad administrator permissions such as PowerUserAccess.
iam:*; it permits only iam:PassRole for the two approved ECS roles

#Task 5

## Issue 1: Incorrect principal in the trust policy

The original trust policy used `arn:aws:iam::000000000000:user/roleB`. This ARN identifies an IAM user, not an IAM role. Since roleB is an IAM role, the correct principal is `arn:aws:iam::000000000000:role/roleB`.


## Issue 2: Overly broad S3 permissions

The original permissions policy used `s3:*` with `Resource: "*"`. This grants S3 permissions across all resources covered by those actions, which violates least privilege.

I replaced it with specific S3 actions and resource ARNs for one named bucket and its objects. Bucket-level actions use the bucket ARN, while object-level actions use the bucket ARN followed by `/*`.



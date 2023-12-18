resource "aws_s3_bucket" "s3_bucket" {
   bucket = "deepak-s3-bucket1"
   } # change this


/*resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
*/

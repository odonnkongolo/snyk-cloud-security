resource "aws_ecr_repository" "threat_detection_repo" {
  name                 = "threat-detection-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}